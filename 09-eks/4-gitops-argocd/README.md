# GitOps with ArgoCD + Argo Rollouts + ArgoCD Image Updater

## Architecture

```
Developer pushes code to backend-repo / frontend-repo
        ↓
EventBridge triggers CodePipeline → CodeBuild
        ↓
CodeBuild: docker build → push image to ECR
        ↓
ArgoCD Image Updater detects new image tag in ECR (every 2 min)
        ↓
Updates ArgoCD Application spec with new image tag
        ↓
ArgoCD syncs k8s/ manifests from backend-repo / frontend-repo
        ↓
Argo Rollouts: spins up green (preview) pods — blue stays active
        ↓
Manual promotion → traffic switches to green
        ↓
Blue pods terminated
```

---

## Directory Structure

```
4-gitops-argocd/
├── helm/
│   └── argocd-values.yaml              # ArgoCD Helm values (insecure, ClusterIP)
├── k8s/
│   ├── backend/
│   │   ├── rollout.yaml                # Argo Rollouts blue/green + services
│   │   └── kustomization.yaml
│   ├── frontend/
│   │   ├── rollout.yaml                # Argo Rollouts blue/green + nginx config
│   │   └── kustomization.yaml
│   ├── argocd-app-backend.yaml         # ArgoCD Application for backend
│   ├── argocd-app-frontend.yaml        # ArgoCD Application for frontend
│   ├── image-updater-backend.yaml      # ImageUpdater CR for backend ECR watching
│   ├── image-updater-frontend.yaml     # ImageUpdater CR for frontend ECR watching
│   └── ecr-token-refresher.yaml        # CronJob to refresh ECR credentials every 6h
├── backend.config
├── data.tf
├── locals.tf
├── main.tf
├── outputs.tf
├── provider.tf
├── terraform.tfvars
└── variables.tf
```

---

## Prerequisites

- `0-baseline` stack applied (EKS cluster, Pod Identity Agent addon enabled)
- `3-cicd` stack applied (CodePipeline, CodeBuild, ECR repos)
- `kubectl` configured to the cluster
- `argocd` CLI installed
- `kubectl-argo-rollouts` plugin installed

### Install CLIs

```bash
# ArgoCD CLI
curl -sSL -o /tmp/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo mv /tmp/argocd /usr/local/bin/argocd

# Argo Rollouts kubectl plugin
curl -sL https://github.com/argoproj/argo-rollouts/releases/latest/download/kubectl-argo-rollouts-linux-amd64 -o /tmp/kubectl-argo-rollouts
sudo mv /tmp/kubectl-argo-rollouts /usr/local/bin/kubectl-argo-rollouts
chmod +x /usr/local/bin/kubectl-argo-rollouts
```

---

## Option A: Automated Setup (Terraform)

### Step 1: Generate SSH key for ArgoCD CodeCommit access

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/argocd-codecommit -N "" -C "argocd-repo-server"
```

### Step 2: Set the public key in terraform.tfvars

```hcl
argocd_ssh_public_key = "<contents of ~/.ssh/argocd-codecommit.pub>"
```

### Step 3: Apply Terraform

```bash
terraform init -backend-config=backend.config
terraform apply
```

This will:
- Install ArgoCD via Helm
- Install Argo Rollouts via Helm
- Install ArgoCD Image Updater
- Create IAM role for `argocd-repo-server` with `codecommit:GitPull` + Pod Identity association
- Create IAM role for `argocd-image-updater-controller` + `ecr-token-refresher` with ECR read + Pod Identity associations
- Create IAM user `argocd-codecommit` with the SSH public key attached

### Step 4: Get the SSH key ID and add repos to ArgoCD

```bash
SSH_KEY_ID=$(terraform output -raw argocd_codecommit_ssh_key_id)

# Port-forward ArgoCD
kubectl port-forward svc/argocd-server -n argocd 8080:80 &

# Get admin password
kubectl get secret argocd-initial-admin-secret -n argocd \
  -o jsonpath="{.data.password}" | base64 -d && echo

# Login
argocd login localhost:8080 --username admin --password <PASSWORD> --insecure

# Add repos
argocd repo add ssh://$SSH_KEY_ID@git-codecommit.ap-southeast-1.amazonaws.com/v1/repos/backend-repo \
  --ssh-private-key-path ~/.ssh/argocd-codecommit --insecure-skip-server-verification

argocd repo add ssh://$SSH_KEY_ID@git-codecommit.ap-southeast-1.amazonaws.com/v1/repos/frontend-repo \
  --ssh-private-key-path ~/.ssh/argocd-codecommit --insecure-skip-server-verification
```

### Step 5: Add k8s manifests to app repos

```bash
# backend-repo
mkdir -p /tmp/backend-repo && cd /tmp/backend-repo
git clone ssh://$SSH_KEY_ID@git-codecommit.ap-southeast-1.amazonaws.com/v1/repos/backend-repo .
cp <path-to>/4-gitops-argocd/k8s/backend/rollout.yaml k8s/rollout.yaml
cp <path-to>/4-gitops-argocd/k8s/backend/kustomization.yaml k8s/kustomization.yaml
git add k8s/ && git commit -m "Add k8s rollout manifests" && git push origin main

# frontend-repo
mkdir -p /tmp/frontend-repo && cd /tmp/frontend-repo
git clone ssh://$SSH_KEY_ID@git-codecommit.ap-southeast-1.amazonaws.com/v1/repos/frontend-repo .
cp <path-to>/4-gitops-argocd/k8s/frontend/rollout.yaml k8s/rollout.yaml
cp <path-to>/4-gitops-argocd/k8s/frontend/kustomization.yaml k8s/kustomization.yaml
git add k8s/ && git commit -m "Add k8s rollout manifests" && git push origin main
```

### Step 6: Configure ArgoCD Image Updater ECR credentials

```bash
# Create ECR credentials secret
aws ecr get-login-password --region ap-southeast-1 --profile ics-sandbox > /tmp/ecr-token.txt
kubectl create secret docker-registry ecr-credentials \
  --docker-server=<ACCOUNT_ID>.dkr.ecr.ap-southeast-1.amazonaws.com \
  --docker-username=AWS \
  --docker-password="$(cat /tmp/ecr-token.txt)" \
  -n argocd

# Patch image updater configmap
kubectl patch configmap argocd-image-updater-config -n argocd --type merge -p \
  '{"data":{"registries.conf":"registries:\n- name: ECR\n  api_url: https://<ACCOUNT_ID>.dkr.ecr.ap-southeast-1.amazonaws.com\n  prefix: <ACCOUNT_ID>.dkr.ecr.ap-southeast-1.amazonaws.com\n  ping: false\n  insecure: false\n  credentials: pullsecret:argocd/ecr-credentials\n  credsexpire: 10h\n"}}'

kubectl rollout restart deployment/argocd-image-updater-controller -n argocd
```

### Step 7: Apply ArgoCD Applications, ImageUpdater CRs, and ECR token refresher

```bash
# Update repoURL SSH key ID in the application manifests first
sed -i "s|APKAU6GDWC3UC5MB4S7D|$SSH_KEY_ID|g" k8s/argocd-app-backend.yaml
sed -i "s|APKAU6GDWC3UC5MB4S7D|$SSH_KEY_ID|g" k8s/argocd-app-frontend.yaml

kubectl apply -f k8s/argocd-app-backend.yaml
kubectl apply -f k8s/argocd-app-frontend.yaml
kubectl apply -f k8s/image-updater-backend.yaml
kubectl apply -f k8s/image-updater-frontend.yaml
kubectl apply -f k8s/ecr-token-refresher.yaml
```

---

## Option B: Manual Setup

### Step 1: Install ArgoCD

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### Step 2: Install Argo Rollouts

```bash
kubectl create namespace argo-rollouts
kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
```

### Step 3: Install ArgoCD Image Updater

```bash
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/stable/config/install.yaml
```

### Step 4: Create IAM roles and Pod Identity associations

```bash
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text --profile ics-sandbox)
CLUSTER_NAME=test-eks

# ArgoCD repo-server role (CodeCommit GitPull)
aws iam create-role \
  --role-name $CLUSTER_NAME-argocd-repo-server-role \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{"Effect": "Allow", "Principal": {"Service": "pods.eks.amazonaws.com"}, "Action": ["sts:AssumeRole", "sts:TagSession"]}]
  }' --profile ics-sandbox

aws iam put-role-policy \
  --role-name $CLUSTER_NAME-argocd-repo-server-role \
  --policy-name codecommit-gitpull \
  --policy-document "{
    \"Version\": \"2012-10-17\",
    \"Statement\": [{\"Effect\": \"Allow\", \"Action\": [\"codecommit:GitPull\"], \"Resource\": [
      \"arn:aws:codecommit:ap-southeast-1:$ACCOUNT_ID:backend-repo\",
      \"arn:aws:codecommit:ap-southeast-1:$ACCOUNT_ID:frontend-repo\"
    ]}]
  }" --profile ics-sandbox

aws eks create-pod-identity-association \
  --cluster-name $CLUSTER_NAME --namespace argocd \
  --service-account argocd-repo-server \
  --role-arn arn:aws:iam::$ACCOUNT_ID:role/$CLUSTER_NAME-argocd-repo-server-role \
  --profile ics-sandbox --region ap-southeast-1

# Image Updater + ECR token refresher role (ECR read)
aws iam create-role \
  --role-name $CLUSTER_NAME-argocd-image-updater-role \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{"Effect": "Allow", "Principal": {"Service": "pods.eks.amazonaws.com"}, "Action": ["sts:AssumeRole", "sts:TagSession"]}]
  }' --profile ics-sandbox

aws iam put-role-policy \
  --role-name $CLUSTER_NAME-argocd-image-updater-role \
  --policy-name ecr-readonly \
  --policy-document '{
    "Version": "2012-10-17",
    "Statement": [{"Effect": "Allow", "Action": ["ecr:GetAuthorizationToken","ecr:BatchCheckLayerAvailability","ecr:GetDownloadUrlForLayer","ecr:BatchGetImage","ecr:DescribeImages","ecr:ListImages"], "Resource": "*"}]
  }' --profile ics-sandbox

aws eks create-pod-identity-association \
  --cluster-name $CLUSTER_NAME --namespace argocd \
  --service-account argocd-image-updater-controller \
  --role-arn arn:aws:iam::$ACCOUNT_ID:role/$CLUSTER_NAME-argocd-image-updater-role \
  --profile ics-sandbox --region ap-southeast-1

aws eks create-pod-identity-association \
  --cluster-name $CLUSTER_NAME --namespace argocd \
  --service-account ecr-token-refresher \
  --role-arn arn:aws:iam::$ACCOUNT_ID:role/$CLUSTER_NAME-argocd-image-updater-role \
  --profile ics-sandbox --region ap-southeast-1
```

### Step 5: Create IAM user and SSH key for CodeCommit

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/argocd-codecommit -N "" -C "argocd-repo-server"

aws iam create-user --user-name argocd-codecommit --profile ics-sandbox
aws iam attach-user-policy --user-name argocd-codecommit \
  --policy-arn arn:aws:iam::aws:policy/AWSCodeCommitReadOnly --profile ics-sandbox

SSH_KEY_ID=$(aws iam upload-ssh-public-key \
  --user-name argocd-codecommit \
  --ssh-public-key-body file://~/.ssh/argocd-codecommit.pub \
  --profile ics-sandbox --query 'SSHPublicKey.SSHPublicKeyId' --output text)

echo "SSH Key ID: $SSH_KEY_ID"
```

### Step 6: Add repos to ArgoCD

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:80 &

PASS=$(kubectl get secret argocd-initial-admin-secret -n argocd \
  -o jsonpath="{.data.password}" | base64 -d)

argocd login localhost:8080 --username admin --password $PASS --insecure

argocd repo add ssh://$SSH_KEY_ID@git-codecommit.ap-southeast-1.amazonaws.com/v1/repos/backend-repo \
  --ssh-private-key-path ~/.ssh/argocd-codecommit --insecure-skip-server-verification

argocd repo add ssh://$SSH_KEY_ID@git-codecommit.ap-southeast-1.amazonaws.com/v1/repos/frontend-repo \
  --ssh-private-key-path ~/.ssh/argocd-codecommit --insecure-skip-server-verification
```

### Step 7: Add k8s manifests and kustomization to app repos

```bash
export AWS_PROFILE=ics-sandbox
git config --global credential.helper '!aws codecommit credential-helper $@'
git config --global credential.UseHttpPath true

# backend-repo
cd /tmp && git clone https://git-codecommit.ap-southeast-1.amazonaws.com/v1/repos/backend-repo
mkdir -p /tmp/backend-repo/k8s
cp <path>/k8s/backend/rollout.yaml /tmp/backend-repo/k8s/
cp <path>/k8s/backend/kustomization.yaml /tmp/backend-repo/k8s/
cd /tmp/backend-repo && git add k8s/ && git commit -m "Add k8s rollout manifests" && git push origin main

# frontend-repo
cd /tmp && git clone https://git-codecommit.ap-southeast-1.amazonaws.com/v1/repos/frontend-repo
mkdir -p /tmp/frontend-repo/k8s
cp <path>/k8s/frontend/rollout.yaml /tmp/frontend-repo/k8s/
cp <path>/k8s/frontend/kustomization.yaml /tmp/frontend-repo/k8s/
cd /tmp/frontend-repo && git add k8s/ && git commit -m "Add k8s rollout manifests" && git push origin main
```

### Step 8: Configure ArgoCD Image Updater for ECR

```bash
# Create ECR credentials secret
aws ecr get-login-password --region ap-southeast-1 --profile ics-sandbox > /tmp/ecr-token.txt
kubectl create secret docker-registry ecr-credentials \
  --docker-server=$ACCOUNT_ID.dkr.ecr.ap-southeast-1.amazonaws.com \
  --docker-username=AWS \
  --docker-password="$(cat /tmp/ecr-token.txt)" \
  -n argocd

# Configure registry
kubectl patch configmap argocd-image-updater-config -n argocd --type merge -p \
  "{\"data\":{\"registries.conf\":\"registries:\n- name: ECR\n  api_url: https://$ACCOUNT_ID.dkr.ecr.ap-southeast-1.amazonaws.com\n  prefix: $ACCOUNT_ID.dkr.ecr.ap-southeast-1.amazonaws.com\n  ping: false\n  insecure: false\n  credentials: pullsecret:argocd/ecr-credentials\n  credsexpire: 10h\n\"}}"

kubectl rollout restart deployment/argocd-image-updater-controller -n argocd
```

### Step 9: Apply all manifests

```bash
kubectl apply -f k8s/argocd-app-backend.yaml
kubectl apply -f k8s/argocd-app-frontend.yaml
kubectl apply -f k8s/image-updater-backend.yaml
kubectl apply -f k8s/image-updater-frontend.yaml
kubectl apply -f k8s/ecr-token-refresher.yaml
```

### Step 10: Delete old Deployments

If the apps were previously deployed with plain `Deployment` resources, delete them to avoid duplicate pods:

```bash
kubectl delete deployment backend -n backend
kubectl delete deployment frontend -n frontend
```

---

## Accessing ArgoCD UI

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:80
```

Open `http://localhost:8080`. Login with username `admin` and password from:

```bash
kubectl get secret argocd-initial-admin-secret -n argocd \
  -o jsonpath="{.data.password}" | base64 -d && echo
```

---

## Argo Rollouts Dashboard

```bash
kubectl argo rollouts dashboard
```

Opens `http://localhost:3100` — shows all rollouts with promotion controls.

---

## Blue/Green Scenarios

### Promote (switch traffic to green)

```bash
kubectl argo rollouts promote backend -n backend
kubectl argo rollouts promote frontend -n frontend
```

### Abort (keep blue, scale down green)

```bash
kubectl argo rollouts abort backend -n backend
kubectl argo rollouts abort frontend -n frontend
```

### Rollback to a previous revision

```bash
kubectl argo rollouts history rollout backend -n backend
kubectl argo rollouts undo backend -n backend --to-revision=<REVISION>
```

### Preview green before promoting

```bash
kubectl port-forward svc/backend-preview -n backend 5001:5000
curl http://localhost:5001/health/ready

kubectl port-forward svc/frontend-preview -n frontend 8081:80
# open http://localhost:8081
```

---

## ECR Token Auto-Refresh

The `ecr-token-refresher` CronJob runs every 6 hours to refresh the `ecr-credentials` secret before it expires. It uses Pod Identity (same IAM role as Image Updater) to call ECR and update the secret.

To trigger a manual refresh:

```bash
kubectl create job ecr-token-refresh-manual --from=cronjob/ecr-token-refresher -n argocd
kubectl logs job/ecr-token-refresh-manual -n argocd
```

---

## Notes

- `autoPromotionEnabled: false` on both Rollouts — promotion is always manual
- ArgoCD Image Updater polls ECR every 2 minutes for new image tags
- ArgoCD `selfHeal: true` — any manual `kubectl` changes to Rollout/Service resources will be reverted
- Frontend nginx proxies `/api/` to `backend-active` — always hits the live backend regardless of frontend rollout state
- The `k8s/` folder in each repo uses Kustomize — required for ArgoCD Image Updater v1.1.1+ to detect the source type
