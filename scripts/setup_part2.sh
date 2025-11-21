#!/bin/bash
# setup_part2.sh
# Usage: sudo bash setup_part2.sh "Your Name"
# Installs nginx and creates index.html with Name, Instance ID, Uptime

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Please run with sudo"
  exit 1
fi

if [[ $# -ne 1 ]]; then
  echo "Usage: sudo bash setup_part2.sh \"Your Name\""
  exit 1
fi

DISPLAY_NAME="$1"
HTML_PATH="/var/www/html/index.html"

# Install requirements
apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install -y nginx curl

systemctl enable --now nginx

# Metadata fetch (works only inside EC2)
INSTANCE_ID="$(curl -s http://169.254.169.254/latest/meta-data/instance-id || echo 'unknown')"
UPTIME_STR="$(uptime -p 2>/dev/null || echo 'unknown')"

# Create HTML file
cat > "$HTML_PATH" <<HTML
<!DOCTYPE html>
<html>
<head>
  <title>DevOps Intern Assignment</title>
  <meta http-equiv="refresh" content="10">
  <style>
    body { font-family: Arial; margin: 40px auto; max-width: 700px; }
    .card { padding: 20px; background: #f8f8f8; border-radius: 10px;
            box-shadow: 0 2px 6px rgba(0,0,0,0.15); }
    h1 { margin-top: 0; }
    p { font-size: 1.1rem; }
  </style>
</head>
<body>
  <div class="card">
    <h1>DevOps Intern Assignment</h1>
    <p><strong>Name:</strong> ${DISPLAY_NAME}</p>
    <p><strong>Instance ID:</strong> ${INSTANCE_ID}</p>
    <p><strong>Server Uptime:</strong> ${UPTIME_STR}</p>
    <small>(Page auto-refreshes every 10 seconds)</small>
  </div>
</body>
</html>
HTML

chown www-data:www-data "$HTML_PATH"
chmod 644 "$HTML_PATH"

echo "Nginx setup complete. Visit: http://<EC2-PUBLIC-IP>"
