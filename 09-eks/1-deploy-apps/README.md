# Deploy Simple CRUD App to EKS

## Prerequisites

- EKS cluster running with:
  - AWS Load Balancer Controller
  - Secrets Store CSI Driver + AWS Provider (`aws-secrets-manager` namespace)
  - EKS Pod Identity Agent
- `kubectl` configured to the cluster
- AWS CLI configured
- Docker

## Project Structure

```
1-deploy-apps/
├── backend/        # Flask API
├── frontend/       # Nginx + static JS
└── k8s/
    ├── namespace.yaml
    ├── secret-provider-class.yaml
    ├── backend.yaml
    ├── frontend.yaml
    └── ingress.yaml
```

## Step 1: Prepare Variables

```bash
PROFILE=""  # set to "--profile <name>" if using named profile, otherwise leave empty
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text $PROFILE)
REGION=ap-southeast-1
REGISTRY=$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com
```

## Step 2: Create ECR Repositories

```bash
aws ecr create-repository --repository-name backend --region $REGION $PROFILE
aws ecr create-repository --repository-name frontend --region $REGION $PROFILE
```

## Step 3: Build and Push Images

```bash
aws ecr get-login-password --region $REGION $PROFILE | docker login --username AWS --password-stdin $REGISTRY
docker build -t $REGISTRY/backend:v1 ./backend && docker push $REGISTRY/backend:v1
docker build -t $REGISTRY/frontend:v1 ./frontend && docker push $REGISTRY/frontend:v1
```

## Step 4: IAM — Pod Identity for Backend

> Already provisioned via Terraform. Ensure the Pod Identity Association is created for the `backend` service account in the `backend` namespace.

## Step 5: Update ingress.yaml

The ingress is pre-configured with subnets, security group, and ACM certificate. No placeholders to replace.

## Step 6: Create Database Table

RDS is in a private subnet, so connect via AWS CloudShell with a VPC environment.

1. Open **AWS CloudShell** in the console
2. Click **Actions → Create VPC environment** and select the VPC and a private subnet
3. Once connected, follow the following commands:

```bash
curl -o global-bundle.pem https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem

export RDSHOST="<UPDATE_RDS_HOST>" 
psql "host=$RDSHOST port=5432 dbname=appdb user=dbadmin sslmode=verify-full sslrootcert=./global-bundle.pem"
```

Then run:

```sql
CREATE TABLE IF NOT EXISTS items (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    image_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

Verify:

```sql
\dt
\q
```

## Step 7: Deploy

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/secret-provider-class.yaml
kubectl apply -f k8s/backend.yaml
kubectl apply -f k8s/frontend.yaml
kubectl apply -f k8s/ingress.yaml
```

## Step 8: Get the App URL

```bash
kubectl get ingress frontend -n frontend
```

## Architecture

```
Internet → ALB → frontend (nginx) → /api/* proxied to backend (ClusterIP)
```

- Frontend is exposed publicly via ALB
- Backend is internal only (ClusterIP), accessible only through nginx proxy
- Secrets are injected via Secrets Store CSI Driver from AWS Secrets Manager

## Verify

```bash
kubectl get pods -n backend && kubectl get pods -n frontend
kubectl exec -n backend deploy/backend -- curl -s localhost:5000/health/ready
```
