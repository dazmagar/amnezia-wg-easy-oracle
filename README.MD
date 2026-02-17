# Amnezia VPN
https://amnezia.org/en

# Amnezia WG Easy
https://github.com/w0rng/amnezia-wg-easy

# Hints
In case of WG updates
``` bash
terraform apply -replace="module.provisioner.null_resource.install_docker"
terraform apply -replace="module.provisioner.null_resource.clone_repository"
terraform apply -replace="module.provisioner.null_resource.build_amnezia_image"
terraform apply -replace="module.provisioner.null_resource.copy_wireguard_configs" # to run this command set variable `enable_wg_configs` = `true`
terraform apply -replace="module.provisioner.null_resource.run_amnezia_docker_container"
terraform apply -replace="module.provisioner.null_resource.setup_cron_restart"
```

## Backup and restore

### Create backup from server to local repo

```bash
# Preferred: run backup via Terraform
terraform apply -replace="module.backup.null_resource.backup_wireguard_configs"

# Alternatively, run PowerShell script directly on Windows:
# (paths should match your environment)
setx PRIVATE_KEY_PATH "C:\Users\dazma\.ssh\id_rsa"
setx USER "ubuntu"
setx INSTANCE_IP "130.162.229.134"
setx BACKUP_PATH "D:\git\edu\terraform\amnezia-wg-easy-oracle\modules\backup\wg_backup"
powershell -File .\modules\backup\backup.ps1
```

### Restore configs from local backup to server

```bash
# Copy wg0.conf / wg0.json from modules/backup/wg_backup back to server
# enable_wg_configs must be set to true in terraform.tfvars
terraform apply -replace="module.provisioner.null_resource.copy_wireguard_configs"
```

## Post-deploy verification

```bash
# MTU must be 1320
docker exec amnezia-wg-easy ip link show wg0

# MSS clamping rules: exactly one per direction
iptables -t mangle -S | grep TCPMSS

# Sysctl tuning
sysctl net.ipv4.ip_forward net.ipv4.tcp_congestion_control
```
