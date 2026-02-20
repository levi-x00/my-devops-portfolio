# Deploy Simple CRUD App to EKS

## Prerequisites

- EKS cluster running with:
  - AWS Load Balancer Controller
  - Secrets Store CSI Driver + AWS Provider
- `kubectl` configured to the cluster
- AWS CLI configured
- Docker

## Project Structure

```
1-deploy-apps/
├── backend/        # Flask API
├── frontend/       # Nginx + static JS
├── postgres/       # DB init SQL
└── k8s/
    ├── namespace.yaml
    ├── secret-provider-class.yaml
    ├── postgres.yaml
    ├── postgres-secret.yaml
    ├── backend.yaml
    └── frontend.yaml
```

## Step 1: Prepare Variables

```bash
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION=ap-southeast-1   # change to your region
REGISTRY=$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com
```

## Step 2: Create ECR Repositories

```bash
aws ecr create-repository --repository-name simple-crud-app2-backend --region $REGION
aws ecr create-repository --repository-name simple-crud-app2-frontend --region $REGION
```

## Step 3: Build and Push Images

```bash
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $REGISTRY

docker build -t $REGISTRY/simple-crud-app2-backend:latest ./backend
docker push $REGISTRY/simple-crud-app2-backend:latest

docker build -t $REGISTRY/simple-crud-app2-frontend:latest ./frontend
docker push $REGISTRY/simple-crud-app2-frontend:latest
```

## Step 4: Update Manifests

Replace placeholders in `k8s/backend.yaml` and `k8s/frontend.yaml`:

```bash
sed -i "s/<ACCOUNT_ID>/$ACCOUNT_ID/g" k8s/backend.yaml k8s/frontend.yaml
sed -i "s/<REGION>/$REGION/g" k8s/backend.yaml k8s/frontend.yaml
```

Replace `<DB_SECRET_NAME>` in `k8s/secret-provider-class.yaml` with your Secrets Manager secret name:

```bash
sed -i "s/<DB_SECRET_NAME>/your-secret-name/g" k8s/secret-provider-class.yaml
```

Also add `AWS_REGION` and `S3_BUCKET` env vars to `k8s/backend.yaml` under the `env` section:

```yaml
- name: AWS_REGION
  value: "ap-southeast-1"
- name: S3_BUCKET
  value: "your-s3-bucket-name"
```

## Step 5: IAM — Pod Identity for Backend

Since the cluster has `pod-identity-agent` installed, create a Pod Identity Association instead of IRSA.

**Create the IAM role** with a trust policy for EKS Pod Identity:

```bash
cat > trust-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "pods.eks.amazonaws.com"
      },
      "Action": ["sts:AssumeRole", "sts:TagSession"]
    }
  ]
}
EOF

aws iam create-role \
  --role-name simple-crud-backend-role \
  --assume-role-policy-document file://trust-policy.json
```

**Attach permissions** to the role:

```bash
cat > permissions-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue",
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:secretsmanager:<REGION>:<ACCOUNT_ID>:secret:<DB_SECRET_NAME>*",
        "arn:aws:s3:::your-s3-bucket-name/*"
      ]
    }
  ]
}
EOF

aws iam put-role-policy \
  --role-name simple-crud-backend-role \
  --policy-name simple-crud-backend-policy \
  --policy-document file://permissions-policy.json
```

**Create the Pod Identity Association:**

```bash
aws eks create-pod-identity-association \
  --cluster-name <CLUSTER_NAME> \
  --namespace backend \
  --service-account backend \
  --role-arn arn:aws:iam::<ACCOUNT_ID>:role/<ROLE_NAME> \
  --region $REGION
```

Make sure your backend deployment uses a service account named `backend` in the `backend` namespace.

## Step 6: Deploy

```bash
# Namespaces
kubectl apply -f k8s/namespace.yaml

# Secrets Store CSI
kubectl apply -f k8s/secret-provider-class.yaml

# PostgreSQL
kubectl apply -f k8s/postgres-secret.yaml
kubectl apply -f k8s/postgres.yaml
kubectl wait --for=condition=ready pod -l app=postgres -n backend --timeout=120s

# Backend
kubectl apply -f k8s/backend.yaml
kubectl wait --for=condition=available deployment/backend -n backend --timeout=120s

# Frontend
kubectl apply -f k8s/frontend.yaml
```

## Step 7: Get the App URL

```bash
kubectl get ingress -n frontend
```

Use the `ADDRESS` from the output to access the app in your browser.

## Verify

```bash
# Check all pods are running
kubectl get pods -n backend
kubectl get pods -n frontend

# Check backend health
kubectl exec -n backend deploy/backend -- curl -s localhost:5000/health
```
