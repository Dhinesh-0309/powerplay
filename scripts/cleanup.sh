#!/bin/bash
# cleanup.sh
# Safety-first cleanup helper for the DevOps assignment.
# - Stops & disables the system_report timer/service
# - Removes local scripts/logs installed by the assignment
# - Prints AWS CLI commands (manual) to delete CloudWatch log group and terminate the instance
#
# IMPORTANT:
# - This script does NOT automatically terminate your EC2 instance or delete AWS resources.
#   It prints the AWS CLI commands you can run manually after review.
# - Review the printed commands before running them.
#
# Usage:
#   sudo bash cleanup.sh
set -euo pipefail

echo
echo "=== STOPPING systemd timer & service ==="
if systemctl list-timers --all | grep -q system_report.timer; then
  sudo systemctl stop system_report.timer || true
  sudo systemctl disable system_report.timer || true
  echo "Stopped & disabled system_report.timer"
else
  echo "system_report.timer not active (or systemd not available)."
fi

if systemctl list-units --type=service | grep -q system_report.service; then
  sudo systemctl stop system_report.service || true
  sudo systemctl disable system_report.service || true
  echo "Stopped & disabled system_report.service"
else
  echo "system_report.service not active (or systemd not available)."
fi

echo
echo "=== REMOVING LOCAL FILES ==="
if [[ -f /usr/local/bin/system_report.sh ]]; then
  sudo rm -f /usr/local/bin/system_report.sh && echo "Removed /usr/local/bin/system_report.sh"
else
  echo "/usr/local/bin/system_report.sh not found"
fi

if [[ -f /usr/local/bin/alert_disk_usage.sh ]]; then
  sudo rm -f /usr/local/bin/alert_disk_usage.sh && echo "Removed /usr/local/bin/alert_disk_usage.sh"
else
  echo "/usr/local/bin/alert_disk_usage.sh not found"
fi

if [[ -f /var/log/system_report.log ]]; then
  sudo rm -f /var/log/system_report.log && echo "Removed /var/log/system_report.log"
else
  echo "/var/log/system_report.log not found"
fi

echo
echo "=== OPTIONAL: Remove nginx webpage (if created by setup_part2) ==="
if [[ -f /var/www/html/index.html ]]; then
  echo "Note: /var/www/html/index.html exists. Remove it manually if you want."
  echo "  sudo rm -f /var/www/html/index.html"
else
  echo "No /var/www/html/index.html found."
fi

echo
echo "=== AWS CLEANUP SUGGESTIONS (MANUAL STEP) ==="
echo "Review and run the following commands only if you understand the consequences."
echo
echo "1) Delete CloudWatch Log Group (if created):"
echo "   aws logs delete-log-group --log-group-name /devops/intern-metrics --region <AWS_REGION>"
echo
echo "2) (Optional) Terminate this EC2 instance:"
echo "   aws ec2 terminate-instances --instance-ids <INSTANCE_ID> --region <AWS_REGION>"
echo
echo "3) (Optional) Remove any IAM policy or role you created for SES/CloudWatch (review first)."
echo
echo "=== DONE ==="
