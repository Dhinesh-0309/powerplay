#!/bin/bash
# upload_to_cloudwatch.sh
# Upload /var/log/system_report.log to CloudWatch Logs
# Usage:
#   export AWS_REGION=us-east-1
#   sudo bash upload_to_cloudwatch.sh

set -euo pipefail

LOGFILE="/var/log/system_report.log"
LOG_GROUP="/devops/intern-metrics"
STREAM_NAME="$(hostname)-$(date +%s)"

# Ensure AWS region is set
if [[ -z "${AWS_REGION:-}" ]]; then
  echo "ERROR: Please set AWS_REGION (example: export AWS_REGION=us-east-1)"
  exit 1
fi

# Ensure AWS CLI is installed
if ! command -v aws >/dev/null 2>&1; then
  echo "ERROR: AWS CLI is not installed."
  exit 1
fi

# Ensure log file exists
if [[ ! -f "$LOGFILE" ]]; then
  echo "ERROR: Log file not found: $LOGFILE"
  exit 1
fi

# Create log group if missing
if ! aws logs describe-log-groups --log-group-name-prefix "$LOG_GROUP" --region "$AWS_REGION" | grep -q "$LOG_GROUP"; then
  aws logs create-log-group --log-group-name "$LOG_GROUP_
#!/bin/bash
# upload_to_cloudwatch.sh
# Upload /var/log/system_report.log to CloudWatch Logs
# Usage:
#   export AWS_REGION=us-east-1
#   sudo bash upload_to_cloudwatch.sh

set -euo pipefail

LOGFILE="/var/log/system_report.log"
LOG_GROUP="/devops/intern-metrics"
STREAM_NAME="$(hostname)-$(date +%s)"

# Ensure AWS region is set
if [[ -z "${AWS_REGION:-}" ]]; then
  echo "ERROR: Please set AWS_REGION (example: export AWS_REGION=us-east-1)"
  exit 1
fi

# Ensure AWS CLI is installed
if ! command -v aws >/dev/null 2>&1; then
  echo "ERROR: AWS CLI is not installed."
  exit 1
fi

# Ensure log file exists
if [[ ! -f "$LOGFILE" ]]; then
  echo "ERROR: Log file not found: $LOGFILE"
  exit 1
fi

# Create log group if missing
if ! aws logs describe-log-groups --log-group-name-prefix "$LOG_GROUP" --region "$AWS_REGION" | grep -q "$LOG_GROUP"; then
  aws logs create-log-group --log-group-name "$LOG_GROUP_
