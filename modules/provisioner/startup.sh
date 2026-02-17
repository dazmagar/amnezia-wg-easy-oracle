#!/bin/bash
set -e

USERNAME="${1:-$(whoami)}"

sudo apt-get update -y
sudo apt-get install -y ca-certificates curl

curl -fsSL https://get.docker.com | sudo sh
sudo groupadd -f docker || true
sudo usermod -aG docker "$USERNAME"

sudo systemctl start docker
sudo systemctl enable docker

sudo apt-get install -y mc ca-certificates curl

sudo apt-get autoremove -y
