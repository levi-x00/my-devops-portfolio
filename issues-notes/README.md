# Issues & Notes

Real troubleshooting write-ups from production incidents — symptom, investigation steps, root cause, fix, and prevention. Proprietary details (domains, account IDs, ARNs) are replaced with placeholders.

| # | Issue | Summary |
|---|-------|---------|
| 1 | [Service healthy but returns intermittent 503](./service-healthy-with-503-return.md) | Target group healthy, but ~50% of requests failed. Root cause: `cross_zone.enabled=false` on the target group with only one target registered, so the ALB node in the other AZ had nothing to route to. |
| 2 | [ECS uploads directory not writable on S3 Files mount](./ecs-s3-files-uploads-permission-denied.md) | ECS app could not write uploads to an Amazon S3 Files mount. Root cause: mount defaults to `root:root`, but Apache workers run as `www-data` (uid 33). Fixed with a scoped `chown` in the launch template user data. A wedged S3 Files manager process on the host was a separate issue, cleared by replacing the instance. |
