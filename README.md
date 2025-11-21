<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>DevOps Intern Assignment — Powerplay</title>
  <style>
    :root{
      --bg:#0f1724;
      --card:#0b1220;
      --muted:#9aa4b2;
      --accent:#5eead4;
      --white:#e6eef6;
      --glass: rgba(255,255,255,0.03);
    }
    body{
      margin:0;
      font-family:Inter, ui-sans-serif, system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial;
      background: linear-gradient(180deg,#071024 0%, #071a2b 100%);
      color:var(--white);
      line-height:1.5;
    }
    .container{max-width:980px;margin:36px auto;padding:28px;background:linear-gradient(180deg, rgba(255,255,255,0.02), rgba(255,255,255,0.01));border-radius:12px;box-shadow: 0 8px 30px rgba(2,6,23,0.6);}
    header h1{margin:0 0 6px;font-size:28px}
    header p{margin:0;color:var(--muted)}
    hr{border:none;border-top:1px solid rgba(255,255,255,0.04);margin:20px 0}
    .flex{display:flex;gap:18px;align-items:center}
    .grid{display:grid;grid-template-columns: 1fr 320px; gap:18px}
    .card{background:var(--card);padding:16px;border-radius:10px;border:1px solid rgba(255,255,255,0.03)}
    pre{background:rgba(0,0,0,0.25);padding:12px;border-radius:8px;overflow:auto;color:var(--muted)}
    code{background:rgba(255,255,255,0.02);padding:2px 6px;border-radius:6px;color:var(--accent)}
    h2{margin:18px 0 8px}
    ul{margin:8px 0 12px 18px}
    img.screenshot{width:100%;border-radius:8px;border:1px solid rgba(255,255,255,0.04);display:block}
    .right-note{font-size:13px;color:var(--muted);padding-left:8px}
    .section{margin-bottom:20px}
    .kbd{background:rgba(255,255,255,0.03);padding:4px 8px;border-radius:6px;border:1px solid rgba(255,255,255,0.02);font-family:monospace;color:var(--white)}
    .btn{display:inline-block;background:var(--accent);color:#012028;padding:8px 12px;border-radius:8px;font-weight:600;text-decoration:none}
    footer{margin-top:30px;text-align:center;color:var(--muted);font-size:13px}
    @media (max-width:980px){ .grid{grid-template-columns:1fr} }
  </style>
</head>
<body>
  <div class="container">
    <header class="section">
      <div class="flex" style="justify-content:space-between">
        <div>
          <h1>DevOps Intern Assignment — Powerplay</h1>
          <p>Complete implementation: EC2 setup, Nginx, monitoring, CloudWatch integration, optional SES alerts, and cleanup automation.</p>
        </div>
        <div class="right-note">
          <div><strong>Original assignment:</strong></div>
          <div>/mnt/data/DevOps Intern Assignment - Powerplay.pdf</div>
        </div>
      </div>
    </header>

    <hr />

    <section class="section">
      <h2>Overview</h2>
      <p>This repository implements the full assignment tasks and includes scripts to automate each step. Summary of parts:</p>
      <ul>
        <li><strong>Part 1</strong> — System setup: create <code>devops_intern</code>, passwordless sudo, hostname. (<code>scripts/setup_part1.sh</code>)</li>
        <li><strong>Part 2</strong> — Nginx web server showing Name, Instance ID and Uptime. (<code>scripts/setup_part2.sh</code>)</li>
        <li><strong>Part 3</strong> — Monitoring script (<code>system_report.sh</code>) running via <code>systemd</code> timer; writes <code>/var/log/system_report.log</code>.</li>
        <li><strong>Part 4</strong> — Upload logs to CloudWatch Logs using the provided script.</li>
        <li><strong>Bonus</strong> — SES-based disk-usage alerts. (<code>scripts/alert_disk_usage.sh</code>)</li>
        <li><strong>Cleanup</strong> — helper script to remove installed artifacts. (<code>scripts/cleanup.sh</code>)</li>
      </ul>
    </section>

    <section class="section card">
      <h2>Architecture</h2>
      <p>Diagram (local copy):</p>
      <!-- Architecture image using the uploaded local path as requested -->
      <img src="/mnt/data/diagram-export-21-11-2025-3_00_33-PM.png" alt="Architecture Diagram" class="screenshot" />
      <p style="margin-top:8px;color:var(--muted)">If you host README on GitHub, replace the above absolute path with <code>screenshots/architecture.png</code> (the repo copy).</p>
    </section>

    <section class="section grid">
      <div>
        <h2>Folder structure</h2>
        <pre><code>
/
├── README.md
├── screenshots/
│   ├── PART_01.png
│   ├── PART-02.png
│   ├── PART_03.png
│   ├── PART_04.png
│   ├── SES_ALERT.png
│   └── architecture.png
├── scripts/
│   ├── setup_part1.sh
│   ├── setup_part2.sh
│   ├── system_report.sh
│   ├── system_report.service
│   ├── system_report.timer
│   ├── upload_to_cloudwatch.sh
│   ├── alert_disk_usage.sh
│   └── cleanup.sh
└── config/
    ├── cron.txt
    ├── cloudwatch-config.json
    └── ses-policy.json
        </code></pre>
      </div>
      <div class="card">
        <h3>Prerequisites</h3>
        <ul>
          <li>Ubuntu 22.04 / 24.04 EC2 instance (t2.micro preferred)</li>
          <li>SSH keypair & security group (port 22 SSH, port 80 HTTP)</li>
          <li>AWS CLI v2 installed <span class="right-note">(or use an IAM role)</span></li>
          <li>For SES: verified sender and recipient (sandbox)</li>
        </ul>
        <h3>Required IAM permissions</h3>
        <pre><code>
logs:CreateLogGroup
logs:CreateLogStream
logs:PutLogEvents
logs:DescribeLogGroups
ses:SendEmail
ses:SendRawEmail
        </code></pre>
      </div>
    </section>

    <section class="section">
      <h2>Usage — step by step</h2>

      <h3>Clone & prepare</h3>
      <pre><code>git clone https://github.com/YOUR_USERNAME/devops-intern-assignment.git
cd devops-intern-assignment
chmod +x scripts/*.sh</code></pre>

      <h3>Part 1 — System setup</h3>
      <pre><code>sudo bash scripts/setup_part1.sh "Your Name"</code></pre>
      <p>Verify as <code>devops_intern</code>:</p>
      <pre><code>sudo su - devops_intern
hostnamectl
grep '^devops_intern:' /etc/passwd
sudo whoami    # should print 'root'</code></pre>
      <p><strong>Screenshot:</strong></p>
      <img src="screenshots/PART-01.png" alt="Part 1 screenshot" class="screenshot" />

      <h3>Part 2 — Nginx website</h3>
      <pre><code>sudo bash scripts/setup_part2.sh "Your Full Name"</code></pre>
      <p>Open <code>http://&lt;EC2_PUBLIC_IP&gt;</code> and verify the webpage shows your name, instance ID and uptime.</p>
      <p><strong>Screenshot:</strong></p>
      <img src="screenshots/PART-02.png" alt="Part 2 screenshot" class="screenshot" />

      <h3>Part 3 — Monitoring & systemd timer</h3>
      <pre><code>sudo cp scripts/system_report.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/system_report.sh
sudo cp scripts/system_report.service /etc/systemd/system/
sudo cp scripts/system_report.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now system_report.timer</code></pre>
      <p>To force entries quickly:</p>
      <pre><code>sudo systemctl start system_report.service
sudo systemctl start system_report.service
sudo tail -n 50 /var/log/system_report.log</code></pre>
      <p><strong>Screenshot:</strong></p>
      <img src="screenshots/PART_03.png" alt="Part 3 screenshot" class="screenshot" />

      <h3>Part 4 — Upload logs to CloudWatch</h3>
      <pre><code>export AWS_REGION=us-east-1
sudo AWS_REGION=$AWS_REGION bash scripts/upload_to_cloudwatch.sh</code></pre>
      <p>Verify in CloudWatch Logs → Log groups → <code>/devops/intern-metrics</code></p>
      <p><strong>Screenshot:</strong></p>
      <img src="screenshots/PART-04.png" alt="Part 4 screenshot" class="screenshot" />
    </section>

    <section class="section card">
      <h2>Bonus — SES Disk Alert</h2>
      <p>Configure SES verified sender & recipient, then edit the script variables:</p>
      <pre><code>EMAIL_FROM="your_verified_sender@example.com"
EMAIL_TO="your_verified_recipient@example.com"</code></pre>
      <p>Install the alert helper:</p>
      <pre><code>sudo cp scripts/alert_disk_usage.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/alert_disk_usage.sh</code></pre>
      <p>To test, temporarily set <code>THRESHOLD=1</code> inside the script and run:</p>
      <pre><code>AWS_REGION=us-east-1 sudo /usr/local/bin/alert_disk_usage.sh</code></pre>
      <p><strong>Screenshot (example / simulated):</strong></p>
      <img src="screenshots/SES_ALERT.png" alt="SES alert screenshot" class="screenshot" />
    </section>

    <section class="section">
      <h2>Cleanup</h2>
      <pre><code>sudo bash scripts/cleanup.sh</code></pre>
      <p>This helper stops and disables the timer/service, removes the scripts and log file, and prints AWS CLI commands you can run manually to delete CloudWatch groups and terminate the instance.</p>
    </section>

    <section class="section">
      <h2>How to stand out — practical ideas to make this project exceptional</h2>
      <p>Instead of a generic “I used Terraform”, here are practical, realistic ways to make your submission stand out to recruiters and engineers reviewing it. Each idea is actionable and you can mention it in your README or implement one as a short demo.</p>
      <ol>
        <li>
          <strong>IAC Skeleton (Terraform module)</strong><br/>
          Add a compact Terraform module that creates the EC2, the security group, and the IAM role (no need to implement 100% — a minimal module that launches the instance and injects the bootstrap scripts is excellent).
        </li>
        <li>
          <strong>User-data Automation</strong><br/>
          Include an EC2 user-data script so the instance can self-provision (user creation, nginx, systemd setup). This demonstrates zero-touch provisioning.
        </li>
        <li>
          <strong>IAM & Least-Privilege</strong><br/>
          Create a minimal IAM policy JSON in the repo (document why each permission exists). Attach it to an instance role — show least-privilege thinking.
        </li>
        <li>
          <strong>Observability Improvements</strong><br/>
          Push basic system metrics (CPU/memory) to CloudWatch Metrics and create one simple CloudWatch alarm (e.g., CPU > 80%) — include a link or screenshot of the alarm.
        </li>
        <li>
          <strong>Automated Tests</strong><br/>
          Add a small test script that verifies endpoints and scripts (e.g., curl the webpage, check log file format). This is great to include in CI.
        </li>
        <li>
          <strong>Dockerized Local Dev</strong><br/>
          Provide a Dockerfile that runs the monitoring script in a container locally so reviewers can run it without AWS.
        </li>
        <li>
          <strong>Documentation & Runbook</strong><br/>
          Add a short "Runbook" document describing failure modes and troubleshooting steps — demonstrates operational thinking.
        </li>
        <li>
          <strong>Small UX polish</strong><br/>
          Improve the served web page with better visuals and a friendly badge showing “last run” timestamp pulled from the log — recruiters notice polish.
        </li>
      </ol>
      <p>You can choose any 1–2 items from the list above to implement and mention it in the README under a “Next steps / How I would extend this” section — this signals practical judgment to reviewers.</p>
    </section>

    <footer>
      <p>Questions? Want me to generate the Terraform skeleton / user-data or produce a Dockerfile for the local run? Tell me which idea you prefer and I’ll scaffold it.</p>
      <p>Generated on: <span style="opacity:0.8">2025-11-21</span></p>
    </footer>
  </div>
</body>
</html>
