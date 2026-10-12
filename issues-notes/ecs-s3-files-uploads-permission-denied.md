# ECS Uploads Directory Not Writable on Amazon S3 Files Mount

**Environment:** AWS ECS (EC2 launch type, `awsvpc`) + Amazon S3 Files (NFS-backed S3) + ASG launch template
**Severity:** Medium — file uploads failing for one app

---

## Symptom

The `finance-apps` ECS service could not write to its uploads directory, which is backed by an **Amazon S3 Files** mount. Uploads were denied or failed silently. During diagnosis, `cd` / `ls` / `touch` under the mount on the host also hung indefinitely, which looked like a second, unrelated problem.

## Environment

- **Cluster:** single EC2 container instance, ASG-managed (Min=1, Max=1, Desired=1)
- **Service:** `finance-apps-service` → task definition `finance-apps`
- **Mount:** S3 Files filesystem `<fs-id>`, access point `<fsap-id>`
  - Host path: `/mnt/s3-uploads/finance-apps`
  - Container path: `/var/www/html/public/uploads`
- **Launch template:** `<lt-id>`, referenced by the ASG as `$Default`

## Investigation

1. **Checked IAM** — the task has an execution role only, no task role. Access to the mount is purely OS/NFS level, not S3 API level, so IAM was not the blocker.
2. **Cloned the task definition** into a temporary `nginx-mount-test` task definition (same volume/mount, plain nginx image) to isolate the container-process-permission variable from the mount/IAM variable.
   - nginx running as **root** wrote to the mount instantly → ruled out IAM, mount, and network.
3. **Checked who actually writes the files** with `docker top` on the live `finance-apps` container. The Apache master process runs as `root`, but the workers that handle uploads run as `www-data` (uid/gid `33`).
4. **Checked the host** with `dmesg -T` and `ps`. The local S3 Files manager process (`[127.0.0.1-manager]`) was stuck in kernel D-state, with continuous `nfs: server 127.0.0.1 not responding, timed out` errors. This explains the hangs on `cd` / `ls` / `touch`.

## Root Cause

Two independent problems:

1. **POSIX ownership mismatch (the real cause of the upload failure).** S3 Files defaults any file or directory without explicit POSIX metadata to `root:root` with `755` (dirs) / `644` (files). `www-data` (uid 33) had no write access to the root-owned mount.
2. **Wedged S3 Files manager on the host (the cause of the hangs).** A stuck NFS backend, not a permission error. D-state is uninterruptible, so the process could not be killed, and no systemd unit was found to restart it cleanly.

## Fix

### 1. Immediate (manual)

```bash
chown -R 33:33 /mnt/s3-uploads/finance-apps
```

Scoped to the `finance-apps` subdirectory only, not the mount root. This avoids touching the S3-Files-internal `.s3files-lost+found-*` directory and other apps' subdirectories that may share the same filesystem.

### 2. Permanent (launch template user data)

Added the same scoped `chown` so every future instance fixes itself on boot. Appended after the existing `mount -t s3files ...` line:

```bash
mkdir -p /mnt/s3-uploads/finance-apps
chown -R 33:33 /mnt/s3-uploads/finance-apps
```

- Created as a new launch template version (all other fields unchanged from the previous version).
- Set the new version as the launch template **default**.
- The ASG references `$Default`, so no ASG update was needed.

### 3. Cleared the wedged host

Since this is a single-instance ASG with no HA, the stuck instance was terminated and the ASG replaced it from the fixed launch template:

```bash
aws autoscaling terminate-instance-in-auto-scaling-group \
  --instance-id <old-instance-id> \
  --no-should-decrement-desired-capacity \
  --profile <profile>
```

`finance-apps-service` rescheduled onto the new instance automatically, with brief downtime during the swap.

## Verification

On the new instance:

- Mount healthy, no NFS timeouts, no D-state processes.
- `/mnt/s3-uploads/finance-apps` owned by `33:33` on boot, no manual step.
- Write test as the worker user succeeded:

  ```bash
  docker exec -u 33:33 <container> touch /var/www/html/public/uploads/test
  ```

- Existing files persisted through the instance swap, since they live in S3 behind the mount, not on the EC2 instance.

## Prevention / Follow-ups

- The `chown` hardcodes uid/gid `33` (Debian `www-data`) to match the current image. If the image or its user mapping changes, revisit this value.
- Prefer fixing ownership at the source: set POSIX uid/gid on the **access point** instead of `chown` in user data, if the S3 Files access point supports it.
- When a container runs a root master process with unprivileged workers (Apache, nginx, php-fpm), test writes **as the worker user**, not root. A root test passing proves nothing about the real failure.
- To isolate mount issues from app issues quickly, run a throwaway task with the same volume and a stock image (the `nginx-mount-test` approach).
- Keep the `chown` scoped to the app subdirectory. The parent mount root is shared with other projects.
- If `cd` / `ls` on the mount hangs, check `dmesg -T` for `nfs: server 127.0.0.1 not responding` and `ps` for D-state processes before assuming a permission problem.
- The launch template is tagged `ManagedBy: Terraform`, but it was updated directly via the AWS CLI. Reconcile with the Terraform source (if it exists elsewhere) to avoid drift on the next `terraform apply`.
- Cleanup: the temporary `nginx-mount-test` task definition may still be `ACTIVE`. Deregister it if no longer needed.
