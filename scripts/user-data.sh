#!/bin/bash
# Ubuntu 24.04 LTS EC2의 사용자 데이터로 실행한다.
set -eu

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y nginx curl
nginx -t
systemctl enable --now nginx
curl --fail --silent --show-error http://localhost/
