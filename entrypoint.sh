#!/bin/sh
set -eu

# Persist the container's own SSH host keys (this server's identity, generated
# below on the /data volume so they survive container restarts.
if [ ! -f /data/ssh/ssh_host_ed25519_key ]; then
	mkdir -p /data/ssh
    ssh-keygen -A #creates 6 files
    cp -p /etc/ssh/ssh_host_*_key* /data/ssh/
fi
cp -p /data/ssh/ssh_host_*_key* /etc/ssh/
chmod 600 /etc/ssh/ssh_host_*_key

# Wire the git user's authorized_keys (one public key per line). Command
# restriction and push-to-create live in the login shell (bgit-shell), so each
# line only needs `restrict` for transport hardening (no pty/forwarding).
AK=/data/.ssh/authorized_keys
mkdir -p /data/.ssh
: > "$AK"
if [ -n "${SSH_AUTHORIZED_KEYS:-}" ]; then
    printf '%s\n' "$SSH_AUTHORIZED_KEYS" | while IFS= read -r key; do
        [ -n "$key" ] || continue
        case $key in \#*) continue ;; esac
        printf 'restrict %s\n' "$key" >> "$AK"
    done
fi
chown git:git /data /data/.ssh "$AK"
chmod 700 /data/.ssh
chmod 600 "$AK"

exec /usr/sbin/sshd -D -e
