#!/bin/bash

# 更新容器中的系统
sudo docker exec -it debian_container bash -c "apt update -y && apt install -y curl jq sudo wget tar unzip"

# 启动容器的 SSH 服务
sudo docker exec -it debian_container bash -c "service ssh start"

# 使用 curl 下载 ngrok（确保使用正确的下载链接）
sudo docker exec -it debian_container bash -c "curl -s https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz -o /tmp/ngrok-v3-stable-linux-amd64.tgz"

# 解压 ngrok 文件
sudo docker exec -it debian_container bash -c "tar -xvzf /tmp/ngrok-v3-stable-linux-amd64.tgz -C /tmp"

# 将 ngrok 移动到 /usr/local/bin 目录
sudo docker exec -it debian_container bash -c "mv /tmp/ngrok /usr/local/bin/"

# 提示用户输入 ngrok 授权令牌
echo "请输入您的 ngrok 授权令牌："
read NGROK_TOKEN

# 设置 ngrok 授权令牌
sudo docker exec -it debian_container bash -c "ngrok config add-authtoken $NGROK_TOKEN"

# 启动 ngrok 隧道
sudo docker exec -it debian_container bash -c "nohup ngrok tcp 22 &"

# 获取 ngrok 隧道地址
TUNNEL_URL=$(sudo docker exec -it debian_container bash -c "curl -s http://localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url'")

echo "容器已启动，SSH 密码为 'Meatbuns'。ngrok 隧道地址为: $TUNNEL_URL"
echo "您可以通过以下命令连接到容器："
echo "ssh root@$TUNNEL_URL -p 22"
