#!/bin/bash
set -e

container_name="amnezia-wg-easy"
cron_schedule="${1:-0 3 * * *}"
cron_command="sudo docker restart ${container_name} >/dev/null 2>&1"
cron_job="${cron_schedule} ${cron_command}"

if ! sudo docker --version &> /dev/null; then
  echo "Warning: Docker is not installed, skipping cron setup"
  exit 0
fi

# Check if cron job already exists (check for container name in cron)
if crontab -l 2>/dev/null | grep -q "${container_name}"; then
  echo "Cron job for ${container_name} restart already exists"
  crontab -l | grep "${container_name}"
  exit 0
fi

# Add cron job
(crontab -l 2>/dev/null; echo "${cron_job}") | crontab -
if [ $? -eq 0 ]; then
  echo "Cron job added successfully: ${cron_job}"
  echo "Current crontab:"
  crontab -l
else
  echo "ERROR: Failed to add cron job"
  exit 1
fi

