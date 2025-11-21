#!/bin/bash
# upload_to_cloudwatch.sh
# Upload /var/log/system_report.log to CloudWatch Logs

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
  aws logs create-log-group --log-group-name "$LOG_GROUP" --region "$AWS_REGION"
fi

# Create new log stream
aws logs create-log-stream \
  --log-group-name "$LOG_GROUP" \
  --log-stream-name "$STREAM_NAME" \
  --region "$AWS_REGION" || true

# Build JSON log events using pure bash/awk (no heredoc issues)
EVENTS_JSON=$(awk '
  NF {
    gsub(/"/, "\\\"", $0);
    printf("{\"timestamp\": %d000, \"message\": \"%s\"},", systime(), $0);
  }
' "$LOGFILE")

# Remove trailing comma
EVENTS_JSON="[${EVENTS_JSON%,}]"

# Upload the log events
aws logs put-log-events \
  --log-group-name "$LOG_GROUP" \
  --log-stream-name "$STREAM_NAME" \
  --log-events "$EVENTS_JSON" \
  --region "$AWS_REGION" >/dev/null 2>&1 || true

echo "Uploaded logs to CloudWatch:"
echo "  Log Group : $LOG_GROUP"
echo "  Stream    : $STREAM_NAME"
