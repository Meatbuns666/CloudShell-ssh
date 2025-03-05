#!/bin/bash

# 1. 下载 Docker 镜像，如果镜像不存在
echo "检查并下载 Debian 镜像..."
docker pull debian:12

# 2. 创建并启动容器
echo "启动并创建容器..."
docker run -d --name debian_container debian:12 bash -c "while true; do sleep 3600; done"

# 3. 安装必需的工具
echo "安装必需的工具..."
docker exec -it debian_container bash -c "apt update -y && apt install -y curl jq sudo wget tar unzip openssh-server screen"

# 4. 启动 SSH 服务
echo "启动 SSH 服务..."
docker exec -it debian_container bash -c "service ssh start"

# 5. 使用 curl 下载 ngrok 安装包
echo "下载 ngrok 安装包..."
docker exec -it debian_container bash -c "curl -s https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz -o /tmp/ngrok-v3-stable-linux-amd64.tgz"

# 6. 解压 ngrok 文件
echo "解压 ngrok 文件..."
docker exec -it debian_container bash -c "tar -xvzf /tmp/ngrok-v3-stable-linux-amd64.tgz -C /tmp"

# 7. 将 ngrok 移动到 /usr/local/bin 目录
echo "将 ngrok 移动到 /usr/local/bin 目录..."
docker exec -it debian_container bash -c "mv /tmp/ngrok /usr/local/bin/"

# 8. 提示用户输入 ngrok 授权令牌
echo "请输入您的 ngrok 授权令牌："
read NGROK_TOKEN

# 9. 配置 ngrok 授权令牌
echo "配置 ngrok 授权令牌..."
docker exec -it debian_container bash -c "ngrok config add-authtoken $NGROK_TOKEN"

# 10. 启动 ngrok 隧道
echo "启动 ngrok 隧道..."
docker exec -it debian_container bash -c "screen ngrok tcp 22"

# 11. 打印容器和 ngrok 地址
echo "容器已启动，SSH 密码请手动修改。"
echo "您可以通过以下命令连接到容器："
echo "docker exec -it debian_container bash"
