# SRE Backup and Truncate Automation

This project automates disk monitoring, database backup verification,
report generation, and safe truncation workflows using shell scripting.

## Project Contents
- `code/` – Shell scripts for backup, verification, and truncation
- `docs/` – Design and execution documentation

## What the Script Does
- Checks disk utilization across cluster nodes
- Verifies daily database backups
- Syncs backups to a central backup server
- Spins up Docker containers for data verification
- Compares live vs backup data counts
- Generates reports for approval
- Supports automated truncate commands after approval

## Technologies Used
- Bash / Shell scripting
- SSH
- rsync
- Docker
- MySQL / MariaDB
- Linux utilities
