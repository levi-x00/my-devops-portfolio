# Service Healthy but Returns Intermittent 503

**Environment:** AWS ECS (Fargate/EC2) + Application Load Balancer
**Severity:** Medium — partial outage, ~50% of requests failing

---

## Symptom

A public-facing service behind an ALB started returning intermittent `503 Service Unavailable`, while the target group showed the registered target as **healthy**. The failure rate was roughly 50% — not a full outage, not a clean pass either.

```
$ for i in $(seq 1 10); do curl -s -o /dev/null -w "%{http_code}\n" https://example-service.com/; done
503
503
503
200
503
503
200
503
503
503
```

## Investigation

1. **Checked target health** — target group showed a single target, state `healthy`. Ruled out a crashed/unhealthy container.
2. **Checked ALB-side vs target-side 5XX metrics** in CloudWatch:
   - `HTTPCode_ELB_5XX_Count` — non-zero, steady drip of errors
   - `HTTPCode_Target_5XX_Count` — zero
   - `TargetResponseTime` — consistently low (~4ms) on successful requests

   This split is the key signal: if the target were erroring, `Target_5XX` would show it. Zero target-side errors with non-zero ELB-side errors means **the load balancer itself is generating the 503s**, not the application.

3. **Tested each ALB node IP directly**, bypassing DNS round-robin:

   ```
   $ dig +short example-service.com
   my-alb-1234567890.region.elb.amazonaws.com.
   <alb-node-ip-az-a>
   <alb-node-ip-az-b>

   $ curl -sk --resolve example-service.com:443:<alb-node-ip-az-a> https://example-service.com/
   200

   $ curl -sk --resolve example-service.com:443:<alb-node-ip-az-b> https://example-service.com/
   503
   ```

   One ALB node (AZ-a) worked every time, the other (AZ-b) failed every time. Since public DNS round-robins between the two node IPs, roughly half of all client requests hit the failing node.

## Root Cause

The ALB had one node per AZ (standard for a multi-AZ ALB), but only **one target was registered**, and it lived in a single AZ. The target group attribute `load_balancing.cross_zone.enabled` had been explicitly set to `false` — overriding the load balancer's own cross-zone setting (`true`).

With cross-zone routing disabled at the target group level:
- Requests landing on the ALB node in the target's AZ → forwarded normally → `200`
- Requests landing on the ALB node in the *other* AZ → no local targets to route to → `503`

Traced via CloudTrail (`ModifyTargetGroupAttributes`) to a Terraform apply that had set `load_balancing.cross_zone.enabled = false` alongside a `deregistration_delay` change — likely an unintended side effect of a broader target group attribute block rather than a deliberate cross-zone decision.

## Fix

Two options, in order of preference:

1. **Register at least one target per AZ** the ALB spans. This is the correct long-term fix — it removes the dependency on cross-zone routing entirely and gives you actual AZ redundancy.
2. **Re-enable cross-zone routing** on the target group (`load_balancing.cross_zone.enabled = true`) as an immediate mitigation. This restores service right away but only masks the underlying single-AZ target placement — if the same Terraform config is re-applied without updating the source, the setting reverts.

Applied option 2 immediately to restore service, tracked option 1 as a follow-up to fix the underlying Terraform and ECS service task placement.

## Prevention

- When a target group serves an ALB spanning multiple AZs, treat "at least one target per AZ" as a hard requirement, not a nice-to-have — a single target defeats the purpose of a multi-AZ ALB regardless of cross-zone settings.
- Don't rely on `load_balancing.cross_zone.enabled: true` as a substitute for proper target distribution. It's a safety net, not a design pattern.
- When reviewing Terraform diffs for target group attributes, check every key in the attribute block individually — attribute blocks are easy to modify by accident when only one setting (e.g. `deregistration_delay`) was intended to change.
- Add a CloudWatch alarm on `HTTPCode_ELB_5XX_Count` (ALB-generated) separate from `HTTPCode_Target_5XX_Count` (app-generated). The split between these two metrics is what made this root cause obvious — without it, this looks identical to a flaky app.
- For quick triage next time: test each ALB node IP directly with `curl --resolve` to rule in/out DNS round-robin masking a per-node problem.
