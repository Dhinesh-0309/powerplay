# DevOps Intern Assignment — Powerplay

**Repository contents:** scripts, systemd units, configs, and helper files to complete the DevOps intern assignment.  
**Original assignment (uploaded):** `/mnt/data/DevOps Intern Assignment - Powerplay.pdf`. :contentReference[oaicite:1]{index=1}

---

## Overview

This project implements the required tasks for the DevOps intern assignment:

- **Part 1 — Environment setup:** create `devops_intern` user, passwordless sudo, set hostname. (`scripts/setup_part1.sh`)
- **Part 2 — Web service:** install Nginx and serve an `index.html` showing Name, Instance ID & Uptime. (`scripts/setup_part2.sh`)
- **Part 3 — Monitoring:** `system_report.sh` collects metrics and appends to `/var/log/system_report.log`. Either run via **systemd timer** (`system_report.timer`) or cron fallback (`config/cron.txt`).
- **Part 4 — AWS Integration:** upload logs to CloudWatch Logs (`scripts/upload_to_cloudwatch.sh`).
- **Bonus:** systemd timer (done) and SES email alert for high disk usage (`scripts/alert_disk_usage.sh`).
- **Cleanup:** helper cleanup script (`scripts/cleanup.sh`).

---

## Architecture (ASCII diagram)

```
                                  +----------------+
                                  |   GitHub Repo  |
                                  |  (scripts + md)|
                                  +--------+-------+
                                           |
                                   git clone / scp
                                           |
                                      EC2 Ubuntu
   Public Internet                    (t2.micro)
User  <--->  ALB/Direct IP  <-- HTTP -- Nginx (port 80)
                       \
                        \-- /usr/local/bin/system_report.sh (runs via systemd timer)
                                |--> /var/log/system_report.log
                                |--> optionally calls alert_disk_usage.sh
                                |
                                +--> scripts/upload_to_cloudwatch.sh --(AWS CLI)--> CloudWatch Logs (/devops/intern-metrics)
                                                                \
                                                                 \--> CloudWatch Console (verify logs)
                                                                 
Optional:
 alert_disk_usage.sh -> AWS SES (send-email)  (SES requires verification / IAM)
```

---

## Folder structure

```
/
├── README.md
├── screenshots/
│   ├── part1.png
│   ├── part2.png
│   └── ...
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
```

---

## Prerequisites (for running on EC2)

- An **Ubuntu** EC2 instance (t2.micro — Free Tier eligible).
- An SSH keypair to access the instance.
- Security Group: allow **SSH (22)** from your IP and **HTTP (80)** from your IP (or 0.0.0.0/0 if permitted).
- AWS CLI v2 installed and configured (or use an **IAM instance role** with required permissions).
- (For SES alerts) AWS SES: verified sender and recipient emails (sandbox mode) or production access.

---

## IAM / Permissions Needed (recommended)

If using an **IAM role** attached to the EC2 instance, grant the following managed/custom permissions:

- CloudWatch Logs:
  - `logs:CreateLogGroup`
  - `logs:CreateLogStream`
  - `logs:PutLogEvents`
  - `logs:DescribeLogGroups`
- SES (if using alerts):
  - `ses:SendEmail`
  - `ses:SendRawEmail`

A sample minimal SES policy is provided in `config/ses-policy.json`.

---

## How to use — Step by step

> These steps assume you have pushed this repo to GitHub and cloned it on your EC2 instance.

1. **Clone the repo on the EC2 instance**
   ```bash
   git clone https://github.com/YOUR_USERNAME/devops-intern-assignment.git
   cd devops-intern-assignment
   ```

2. **Make scripts executable**
   ```bash
   chmod +x scripts/*.sh
   ```

3. **Part 1 — Run environment setup**
   ```bash
   sudo bash scripts/setup_part1.sh YOURNAME
   ```
   Verification (as `devops_intern`):
   ```bash
   sudo su - devops_intern
   hostnamectl
   grep '^devops_intern:' /etc/passwd
   sudo whoami   # should print 'root' without password prompt
   ```

4. **Part 2 — Web service**
   ```bash
   sudo bash scripts/setup_part2.sh "Your Full Name"
   ```
   Visit: `http://<EC2_PUBLIC_IP>` — capture screenshot.

5. **Part 3 — Monitoring (systemd timer)**
   - Copy the report script to a system path and enable timer:
     ```bash
     sudo cp scripts/system_report.sh /usr/local/bin/system_report.sh
     sudo chmod +x /usr/local/bin/system_report.sh
     sudo cp scripts/system_report.service /etc/systemd/system/system_report.service
     sudo cp scripts/system_report.timer /etc/systemd/system/system_report.timer
     sudo systemctl daemon-reload
     sudo systemctl enable --now system_report.timer
     ```
   - Check timer status:
     ```bash
     systemctl list-timers --all | grep system_report
     journalctl -u system_report.service -n 50
     ```
   - After two runs (≥10 minutes), verify `/var/log/system_report.log` and capture screenshot lines.

   *Cron alternative:* copy `config/cron.txt` to `/etc/cron.d/system_report` and reload cron.

6. **Part 4 — AWS CloudWatch upload**
   - Ensure AWS CLI is configured (`aws configure`) or instance role has permission.
   - Export region:
     ```bash
     export AWS_REGION=us-east-1
     sudo bash scripts/upload_to_cloudwatch.sh
     ```
   - Verify in AWS Console: CloudWatch Logs → `/devops/intern-metrics`. Capture screenshot.

7. **Bonus — SES Disk Alert**
   - Edit `scripts/alert_disk_usage.sh` and set `EMAIL_FROM` and `EMAIL_TO` (both must be SES verified in sandbox).
   - Ensure `scripts/alert_disk_usage.sh` is placed at `/usr/local/bin/alert_disk_usage.sh` and executable:
     ```bash
     sudo cp scripts/alert_disk_usage.sh /usr/local/bin/alert_disk_usage.sh
     sudo chmod +x /usr/local/bin/alert_disk_usage.sh
     ```
   - The `system_report.sh` will call the alert script after each run; to test, temporarily lower the threshold or artificially fill disk.

8. **Cleanup (when done)**
   ```bash
   sudo bash scripts/cleanup.sh
   ```
   Then optionally run AWS CLI commands printed by `cleanup.sh` to delete CloudWatch log group and terminate the instance.

---

## Screenshots checklist (what to capture & include in submission)

- **Part1:** `hostnamectl` (showing `<YOURNAME>-devops`), `/etc/passwd` entry for `devops_intern`, `sudo whoami` output (as `devops_intern`).
- **Part2:** Browser screenshot of `http://<EC2_PUBLIC_IP>` showing name, instance ID, uptime.
- **Part3:** `/var/log/system_report.log` showing at least two entries (after two timer runs).
- **Part4:** CloudWatch Logs view showing uploaded log events under `/devops/intern-metrics`.
- **Bonus:** Sample SES email (if triggered) or SES console screenshot showing sent emails.

Name screenshots clearly (e.g., `part1_hostname.png`, `part2_webpage.png`, `part3_log.png`, `part4_cloudwatch.png`).

---

## Troubleshooting & Notes

- **SSH key issues:** If you can’t SSH as `devops_intern`, ensure `/home/devops_intern/.ssh/authorized_keys` exists and has correct ownership/permissions.
- **systemd timer not firing:** `sudo systemctl status system_report.timer` and `journalctl -u system_report.service` will show errors.
- **CloudWatch PutLogEvents sequence token errors:** The upload script uses a new log stream per run to avoid token handling. For long-term use, implement proper `nextSequenceToken` handling.
- **SES sandbox:** By default SES is in sandbox — both source and destination emails must be verified. Request production access to send to arbitrary addresses.
- **Permissions:** If you prefer not to configure AWS creds on the instance, use an **IAM instance role** with CloudWatch and SES permissions.

---

## Security considerations

- The repo contains scripts that autocomplete SSH keys if copying from `/home/ubuntu/.ssh/authorized_keys`. Verify keys before copying.
- The `sudoers` entry grants passwordless sudo to `devops_intern` for assignment convenience; do **not** use such permissions in production without review.
- Always remove demo resources (EC2, CloudWatch log groups) to avoid accidental costs.

---

## Future improvements (non-required, professional note)

This assignment is implemented using ad-hoc shell scripts to match the task requirements. In a real-world environment I would codify the entire setup using **Infrastructure as Code (IaC)** such as **Terraform** or **AWS CloudFormation** to make it fully reproducible. Example items to codify with Terraform:

- EC2 instance + security group
- IAM role & policies for CloudWatch and SES
- CloudWatch Log Group & Log Stream creation
- User-data script to run initial provisioning

Adding Terraform would not be included unless requested — it's listed here as a practical, professional next step.

---

## Submission checklist

- [ ] All scripts present in `scripts/` and executable
- [ ] README.md present and describes steps (this file)
- [ ] All required screenshots saved to `screenshots/` with descriptive names
- [ ] GitHub repository URL (or ZIP) prepared for submission
- [ ] Confirmed CloudWatch logs present and SES tested (if implemented)

---

## Contact / Notes

If you want, I can now:
- Generate a polished **GitHub README** (this file is ready to save), or
- Produce a Terraform skeleton that mirrors the assignment (separate optional task), or
- Walk you through launching the EC2 instance and cloning the repo step-by-step.

Tell me which you prefer next.
