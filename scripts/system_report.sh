#!/bin/bash
# system_report.sh
# Purpose: collect basic system metrics and append them to /var/log/system_report.log
# Intended location on EC2: /usr/local/bin/system_report.sh
# Make executable: chmod +x /usr/local/bin/system_report.sh
#
# Metrics:
# - timestamp (ISO)
# - uptime (human)
# - CPU usage (%)
# - Memory usage (%)
# - Disk usage (root %)
# - Top 3 processes by CPU
#
# The script will optionally call /usr/local/bin/alert_disk_usage.sh if present and executable.

set -euo pipefail

LOGFILE="/var/log/system_report.log"

# Ensure log dir and file exist with sane permissions
mkdir -p "$(dirname "$LOGFILE")"
if [[ ! -f "$LOGFILE" ]]; then
  touch "$LOGFILE"
  chmod 644 "$LOGFILE"
fi

timestamp() {
  date --iso-8601=seconds
}

# CPU usage (approximate): use top to compute % used (100 - idle)
cpu_usage() {
  # Parse top output: find the "Cpu(s)" line and extract idle value, then compute used.
  local idle
  idle=$(top -bn1 | awk -F',' '/Cpu\(s\)/ { for(i=1;i<=NF;i++){ if($i ~ /id/){ print $i } } }' | awk '{print $1}' | sed 's/%id//;s/ //g' | head -n1)
  if [[ -z "$idle" ]]; then
    echo "0.00"
  else
    # Use bc-like printf arithmetic through awk to avoid dependency on bc
    awk -v id="$idle" 'BEGIN { used=100 - id; printf("%.2f", used) }'
  fi
}

# Memory usage percentage
mem_usage() {
  free | awk '/Mem:/ { printf("%.2f", $3/$2 * 100) }'
}

# Disk usage of root filesystem (percent string like 12%)
disk_usage() {
  df -P / | awk 'NR==2 {print $5}'
}

# Top 3 processes by CPU (pid, %cpu, command)
top_procs() {
  ps -eo pid,pcpu,comm --sort=-pcpu | head -n 4 | tail -n 3
}

# Compose the report and append to logfile
{
  echo "===== $(timestamp) ====="
  echo "Uptime: $(uptime -p 2>/dev/null || echo 'unknown')"
  echo "CPU(%): $(cpu_usage)"
  echo "Memory(%): $(mem_usage)"
  echo "Disk(/) : $(disk_usage)"
  echo "Top 3 CPU processes:"
  top_procs
  echo
} >> "$LOGFILE"

# Optional: run alert helper if present
if [[ -x "/usr/local/bin/alert_disk_usage.sh" ]]; then
  /usr/local/bin/alert_disk_usage.sh || true
fi

exit 0

