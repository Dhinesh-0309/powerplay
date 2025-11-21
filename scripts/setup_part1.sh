#!/bin/bash
# setup_part1.sh
# Usage: sudo bash setup_part1.sh YOURNAME
# Creates devops_intern user, passwordless sudo, sets hostname.

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Please run as sudo/root"
  exit 1
fi

if [[ $# -ne 1 ]]; then
  echo "Usage: sudo bash setup_part1.sh YOURNAME"
  exit 1
fi

YOURNAME="$1"
USERNAME="devops_intern"
NEW_HOSTNAME="${YOURNAME}-devops"
USER_HOME="/home/${USERNAME}"

# 1) Create user if not exists
if id -u "$USERNAME" >/dev/null 2>&1; then
  echo "User $USERNAME already exists"
else
  echo "Creating user $USERNAME..."
  adduser --disabled-password --gecos "" "$USERNAME"
  mkdir -p "$USER_HOME/.ssh"
  chown -R "$USERNAME:$USERNAME" "$USER_HOME/.ssh"
  chmod 700 "$USER_HOME/.ssh"
fi

# 2) Passwordless sudo
SUDOERS_FILE="/etc/sudoers.d/${USERNAME}"
if [[ ! -f "$SUDOERS_FILE" ]]; then
  echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > "$SUDOERS_FILE"
  chmod 0440 "$SUDOERS_FILE"
fi

# 3) Copy ubuntu's authorized_keys to new user (optional but helpful)
if [[ -f /home/ubuntu/.ssh/authorized_keys ]]; then
  cp /home/ubuntu/.ssh/authorized_keys "$USER_HOME/.ssh/authorized_keys"
  chown "$USERNAME:$USERNAME" "$USER_HOME/.ssh/authorized_keys"
  chmod 600 "$USER_HOME/.ssh/authorized_keys"
fi

# 4) Change hostname
CURRENT_HOSTNAME=$(hostname)
if [[ "$CURRENT_HOSTNAME" != "$NEW_HOSTNAME" ]]; then
  hostnamectl set-hostname "$NEW_HOSTNAME"
  echo "127.0.1.1 $NEW_HOSTNAME" >> /etc/hosts
fi

echo
echo "=== Setup Complete ==="
echo "Switch to new user and verify:"
echo "  sudo su - devops_intern"
echo "  hostnamectl"
echo "  grep '^devops_intern:' /etc/passwd"
echo "  sudo whoami"
