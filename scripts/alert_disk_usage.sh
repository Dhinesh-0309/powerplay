#!/bin/bash
# alert_disk_usage.sh
# Sends SES email alert when disk usage exceeds threshold.
# Requires:
#   - AWS CLI configured (or IAM instance role)
#   - Verified SES sender & recipient emails
# Usage:
#   export AWS_REGION=us-east-1
#   ./alert_disk_usage.sh
#
# This script is automatically called by system_report.sh if placed in:
#   /usr/local/bin/alert_disk_usage.sh

set -euo pipefail

THRESHOLD=80
EMAIL_FROM="verified-sender@example.com"     # <-- replace with SES-verified sender
EMAIL_TO="verified-recipient@example.com"    # <-- replace with SES-verified recipient
AWS_REGION="${AWS_REGION:-us-east-1}"

# Get disk usage of root filesystem (strip %)
USAGE_RAW=$(df -P / | awk 'NR==2 {print $5}')
USAGE=${USAGE_RAW%%%}

if (( USAGE < THRESHOLD )); then
  # Nothing to do
  exit 0
fi

SUBJECT="ALERT: Disk usage on $(hostname) is ${USAGE}%"
BODY="Warning: Disk usage on server $(hostname) has reached ${USAGE}%.\nThreshold: ${THRESHOLD}%\nTime: $(date --iso-8601=seconds)\n"

aws ses send-email \
  --region "$AWS_REGION" \
  --from "$EMAIL_FROM" \
  --destination "ToAddresses=$EMAIL_TO" \
  --message "Subject={Data=$SUBJECT},Body={Text={Data=$BODY}}" || true

echo "Disk alert sent (usage ${USAGE}%)."
