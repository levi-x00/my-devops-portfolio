# GitOps ArgoCD Stack

Terraform stack that installs ArgoCD and Argo Rollouts on EKS and sets up a GitOps workflow with blue/green deployment for backend and frontend services.

## Architecture

```
CodeCommit (gitops-repo)
        ↓
    ArgoCD syncs
        ↓
Argo Rollouts (blue/green)
        ↓
  EKS (backend / frontend)
```

### Blue/Green Flow

```
New image pushed to ECR
        ↓
Update image tag in gitops-repo
        ↓
ArgoCD detects change, syncs Rollout
        ↓
Argo Rollouts spins up preview (green) pods
        ↓
Manual promotion via ArgoCD UI or CLI
        ↓
Active service switches to green pods
        ↓
Old (blue) pods terminated
```

## Prerequisites

- `0-baseline` stack applied
- `01-network-stack` applied
- `kubectl` installed locally
- `aws-codecommit-credential-helper` installed locally

## Usage

```bash
terraform init -backend-config=backend.config
terraform apply
```

### Access ArgoCD UI

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Then open `https://localhost:8080`. Get the initial admin password:

```bash
kubectl get secret argocd-initial-admin-secret -n argocd \
  -o jsonpath="{.data.password}" | base64 -d
```

### Apply ArgoCD Applications

After `terraform apply`, apply the ArgoCD Application manifests:

```bash
kubectl apply -f k8s/argocd-app-backend.yaml
kubectl apply -f k8s/argocd-app-frontend.yaml
```

> Update `repoURL: GITOPS_REPO_URL` in both files with the `gitops_repo_clone_url` output value before applying.

### Promote Blue/Green Deployment

```bash
# via CLI
kubectl argo rollouts promote backend -n backend
kubectl argo rollouts promote frontend -n frontend

# watch rollout status
kubectl argo rollouts get rollout backend -n backend --watch
```

## Directory Structure

```
4-gitops-argocd/
├── helm/
│   └── argocd-values.yaml       # ArgoCD Helm values
├── k8s/
│   ├── argocd-app-backend.yaml  # ArgoCD Application for backend
│   ├── argocd-app-frontend.yaml # ArgoCD Application for frontend
│   ├── backend/
│   │   └── rollout.yaml         # Argo Rollouts blue/green for backend
│   └── frontend/
│       └── rollout.yaml         # Argo Rollouts blue/green for frontend
├── backend.config
├── data.tf
├── locals.tf
├── main.tf
├── outputs.tf
├── provider.tf
├── variables.tf
└── terraform.tfvars
```

## Inputs

| Name | Description | Type | Default | Required |
|---|---|---|---|---|
| environment | Environment name | `string` | `dev` | no |
| application | Application name | `string` | `myapp` | no |
| aws_region | AWS region | `string` | `ap-southeast-1` | no |
| aws_profile | AWS CLI profile | `string` | `ics-sandbox` | no |
| argocd_version | ArgoCD Helm chart version | `string` | `7.8.23` | no |
| argo_rollouts_version | Argo Rollouts Helm chart version | `string` | `2.39.5` | no |
| gitops_repository_name | CodeCommit repository name for GitOps manifests | `string` | `gitops-repo` | no |
| git_user_email | Git user email for initial commit | `string` | - | yes |
| git_user_name | Git user name for initial commit | `string` | - | yes |
| tfstate_bucket | S3 bucket for Terraform remote state | `string` | - | yes |
| network_tfstate_key | S3 key for network stack tfstate | `string` | - | yes |
| eks_tfstate_key | S3 key for EKS baseline tfstate | `string` | - | yes |

## Outputs

| Name | Description |
|---|---|
| argocd_namespace | Namespace where ArgoCD is installed |
| gitops_repo_clone_url | HTTPS clone URL for the GitOps CodeCommit repository |

## Notes

- `autoPromotionEnabled: false` on both Rollouts — manual promotion is required before traffic switches to the new version
- The frontend nginx config proxies `/api/` to `backend-active` service so it always hits the live backend
- The `k8s/` directory is pushed to the GitOps CodeCommit repo via `null_resource` on `terraform apply`
- Update `repoURL` in `argocd-app-backend.yaml` and `argocd-app-frontend.yaml` with the actual CodeCommit clone URL after apply
