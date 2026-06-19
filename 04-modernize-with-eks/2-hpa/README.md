# Horizontal Pod Autoscaler & Pod Disruption Budget

## Horizontal Pod Autoscaler (HPA)

HPA automatically scales the number of pod replicas in a Deployment based on observed metrics such as CPU or memory utilization. When load increases, HPA adds more pods; when load drops, it scales them back down.

How it works:
- The metrics-server collects resource usage from pods
- HPA queries metrics-server periodically (default every 15s)
- If current utilization exceeds the target threshold, HPA increases replicas
- If utilization drops below the threshold, HPA decreases replicas (respecting `minReplicas`)

Example: if target CPU is 50% and average usage across pods is 80%, HPA will scale up until average drops to ~50%.

## Pod Disruption Budget (PDB)

PDB limits the number of pods that can be simultaneously unavailable during voluntary disruptions — such as node drains, cluster upgrades, or rolling deployments.

- `minAvailable` — minimum number (or percentage) of pods that must remain running
- `maxUnavailable` — maximum number (or percentage) of pods that can be down at once

PDB only applies to **voluntary** disruptions (e.g. `kubectl drain`). It does not protect against node failures or OOM kills.

Example: with `minAvailable: 1` and 2 replicas, a node drain will wait until a replacement pod is running before evicting the second pod.

## Prerequisites

- `metrics-server` addon installed on the cluster (already included in `cluster_addons`)
- Deployments already running (`backend` and `frontend` namespaces)

## Step 1: Apply HPA

```bash
kubectl apply -f k8s/hpa.yaml
```

Verify:

```bash
kubectl get hpa -n backend
kubectl get hpa -n frontend
```

Watch live scaling activity:

```bash
kubectl get hpa -n backend -w
```

## Step 2: Apply Pod Disruption Budget

```bash
kubectl apply -f k8s/pdb.yaml
```

Verify:

```bash
kubectl get pdb -n backend
kubectl get pdb -n frontend
```

## Step 3: Verify HPA is Collecting Metrics

```bash
kubectl describe hpa -n backend
kubectl describe hpa -n frontend
```

The `Metrics` section should show current vs target utilization. If it shows `<unknown>`, wait a minute for metrics-server to collect data or check that resource `requests` are set on the container — HPA requires them to calculate utilization percentage.
