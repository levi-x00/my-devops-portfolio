# Issues & Notes

Real troubleshooting write-ups from production incidents — symptom, investigation steps, root cause, fix, and prevention. Proprietary details (domains, account IDs, ARNs) are replaced with placeholders.

| # | Issue | Summary |
|---|-------|---------|
| 1 | [Service healthy but returns intermittent 503](./service-healthy-with-503-return.md) | Target group healthy, but ~50% of requests failed. Root cause: `cross_zone.enabled=false` on the target group with only one target registered, so the ALB node in the other AZ had nothing to route to. |
