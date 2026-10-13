#!/usr/bin/env bash
# Debian 一键安装 Docker Engine(官方源)
# 用法:  bash install-docker.sh
# 国内镜像源:  MIRROR=https://mirrors.aliyun.com/docker-ce/linux bash install-docker.sh
set -euo pipefail

MIRROR="${MIRROR:-https://download.docker.com/linux}"

if [[ $EUID -ne 0 ]]; then
  echo "请用 root 运行,或: sudo bash $0" >&2
  exit 1
fi

echo "==> 安装依赖"
apt-get update -qq
apt-get install -y -qq ca-certificates curl

echo "==> 添加 Docker 官方 GPG 密钥"
install -m 0755 -d /etc/apt/keyrings
curl -fsSL "$MIRROR/debian/gpg" -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo "==> 添加 Docker 软件源"
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
$MIRROR/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  > /etc/apt/sources.list.d/docker.list

echo "==> 安装 Docker Engine"
apt-get update -qq
apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "==> 设置开机自启"
systemctl enable --now docker

echo "==> 验证(拉取并运行 hello-world)"
docker run --rm hello-world

echo
echo "Docker 安装完成 ✔  $(docker --version)"
echo "提示: 想免 sudo 用 docker, 执行 sudo usermod -aG docker \$USER 后重新登录"
