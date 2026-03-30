#!/bin/sh
set -e

ssh-keygen -A

if [ -n "$SSH_AUTHORIZED_KEYS" ]; then
    echo "command=\"/usr/local/bin/bgit-jail\",no-port-forwarding,no-agent-forwarding,no-pty $SSH_AUTHORIZED_KEYS" \
        > /home/git/.ssh/authorized_keys
    chown git:git /home/git/.ssh/authorized_keys
    chmod 600 /home/git/.ssh/authorized_keys
fi

/usr/sbin/sshd
export BGIT_STORE=/data
exec ./cgit-serve
