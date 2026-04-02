# Monitoring with Prometheus + Grafana on EKS

## Architecture

```
EKS Cluster
        ↓
kube-prometheus-stack (Helm)
        ├── Prometheus        — metrics collection + alerting (EBS gp3)
        ├── Alertmanager      — alert routing (EBS gp3)
        ├── Grafana           — dashboards + visualization (EBS gp3)
        ├── node-exporter     — node-level metrics (DaemonSet)
        └── kube-state-metrics — Kubernetes object metrics
```

---

## Directory Structure

```
5-monitoring/
├── helm/
│   └── values.yaml       # kube-prometheus-stack Helm values
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

- `0-baseline` stack applied (EKS cluster, EBS CSI driver addon)
- `kubectl` configured to the cluster
- `helm` installed

---

## Option A: Automated Setup (Terraform)

### Step 1: Set Grafana admin password

Update `terraform.tfvars`:

```hcl
grafana_admin_password = "<your-password>"
```

### Step 2: Apply Terraform

```bash
terraform init -backend-config=backend.config
terraform apply
```

This will:
- Create `monitoring` namespace
- Create `gp3` StorageClass backed by EBS
- Install `kube-prometheus-stack` via Helm with:
  - Prometheus with 50Gi EBS persistence + 15d retention
  - Alertmanager with 10Gi EBS persistence
  - Grafana with 10Gi EBS persistence
  - Node Exporter + kube-state-metrics
  - Internal ALB Ingress (shared) for Prometheus and Grafana

### Step 3: Access via port-forward

```bash
# Grafana
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80

# Prometheus
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090
```

Access:
- Grafana: `http://localhost:3000`
- Prometheus: `http://localhost:9090`

---

## Option B: Manual Setup

### Step 1: Add Helm repositories

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```

### Step 2: Create namespace

```bash
kubectl create namespace monitoring
```

### Step 3: Create gp3 StorageClass

```bash
cat <<EOF | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: gp3
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: ebs.csi.aws.com
reclaimPolicy: Retain
allowVolumeExpansion: true
volumeBindingMode: WaitForFirstConsumer
parameters:
  type: gp3
  encrypted: "true"
EOF
```

### Step 4: Install kube-prometheus-stack

```bash
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set grafana.adminPassword=<your-password> \
  --set prometheus.prometheusSpec.retention=15d \
  --set prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.storageClassName=gp3 \
  --set prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage=50Gi \
  --set alertmanager.alertmanagerSpec.storage.volumeClaimTemplate.spec.storageClassName=gp3 \
  --set alertmanager.alertmanagerSpec.storage.volumeClaimTemplate.spec.resources.requests.storage=10Gi \
  --set grafana.persistence.enabled=true \
  --set grafana.persistence.storageClassName=gp3 \
  --set grafana.persistence.size=10Gi
```

### Step 5: Verify pods are running

```bash
kubectl get pods -n monitoring
```

### Step 6: Access Prometheus and Grafana

**Option 1 — Port forward (local access):**

```bash
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
```

- Prometheus: `http://localhost:9090`
- Grafana: `http://localhost:3000`

**Option 2 — Expose via internal ALB Ingress (shared load balancer):**

```bash
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: monitoring
  namespace: monitoring
  annotations:
    alb.ingress.kubernetes.io/scheme: internal
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/group.name: monitoring
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}]'
spec:
  ingressClassName: alb
  rules:
    - http:
        paths:
          - path: /grafana
            pathType: Prefix
            backend:
              service:
                name: prometheus-grafana
                port:
                  number: 80
          - path: /prometheus
            pathType: Prefix
            backend:
              service:
                name: prometheus-kube-prometheus-prometheus
                port:
                  number: 9090
EOF
```

Get the ALB DNS:

```bash
kubectl get ingress -n monitoring
```

Access:
- Grafana: `http://<alb-dns>/grafana`
- Prometheus: `http://<alb-dns>/prometheus`

---

## Step 7: Configure Grafana Dashboards

Default credentials:
- Username: `admin`
- Password: value set in `grafana_admin_password` (default from chart: `prom-operator`)

> Change your password after first login.

### Prometheus Data Source

If installed via `kube-prometheus-stack`, the Prometheus datasource is auto-configured. To verify:

1. Go to **Connections → Data Sources**
2. Confirm `Prometheus` datasource points to:
   ```
   http://prometheus-kube-prometheus-prometheus.monitoring.svc:9090
   ```

### Import Pre-Built Dashboards

1. Go to **Dashboards → New → Import**
2. Enter a dashboard ID from [grafana.com/grafana/dashboards](https://grafana.com/grafana/dashboards)

Recommended dashboards:
| Dashboard | ID |
|---|---|
| Node Exporter Full | 1860 |
| Kubernetes Cluster | 7249 |
| Kubernetes Pods | 6417 |
| EKS Cluster | 17119 |

---

## Step 8: Configure Alerts

Edit the Alertmanager configmap to add alert rules:

```bash
kubectl edit configmap -n monitoring prometheus-kube-prometheus-alertmanager
```

Example — high CPU alert:

```yaml
alert: HighCPUUsage
expr: sum(rate(container_cpu_usage_seconds_total[5m])) by (instance) > 0.85
for: 2m
labels:
  severity: critical
annotations:
  summary: "Instance {{ $labels.instance }} CPU usage is over 85%"
  description: "CPU usage is above 85% for the past 2 minutes."
```

---

## Upgrading

To upgrade the Helm chart or update values:

```bash
helm upgrade prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  -f helm/values.yaml
```

Or via Terraform:

```bash
terraform apply
```

---

## Notes

- Prometheus and Grafana use `gp3` EBS volumes with `Retain` reclaim policy — data persists even if pods are deleted
- NLB is set to `internal` scheme — only accessible within the VPC
- `node-exporter` runs as a DaemonSet on every node — collects CPU, memory, disk, network metrics
- `kube-state-metrics` collects Kubernetes object metrics (deployments, pods, etc.)
- Default Grafana dashboards for Kubernetes are pre-installed
- Prometheus scrapes all namespaces by default
