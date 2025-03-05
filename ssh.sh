#!/bin/bash

# 更新系统并安装必要的工具
sudo apt update
sudo apt install -y curl jq sudo tar unzip

# 拉取 Debian 12 镜像
sudo docker pull debian:12

# 创建并启动一个新的 Debian 容器（确保容器持续运行）
sudo docker run -d --name debian_container -p 2222:22 debian:12 tail -f /dev/null

# 进入容器并安装 SSH 服务
sudo docker exec -it debian_container bash -c "apt update && apt install -y openssh-server sudo curl jq tar unzip"

# 设置 SSH 密码为 Meatbuns
sudo docker exec -it debian_container bash -c "echo 'root:Meatbuns' | chpasswd"

# 启动 SSH 服务
sudo docker exec -it debian_container bash -c "service ssh start"

# 使用 curl 下载 ngrok
sudo docker exec -it debian_container bash -c "curl -s https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz -o /tmp/ngrok-v3-stable-linux-amd64.tgz"

# 解压 ngrok 文件并移动到正确的位置
sudo docker exec -it debian_container bash -c "tar -xvzf /tmp/ngrok-v3-stable-linux-amd64.tgz -C /tmp"
sudo docker exec -it debian_container bash -c "mv /tmp/ngrok /usr/local/bin/"

# 提示用户输入 ngrok 授权令牌
echo "请输入您的 ngrok 授权令牌："
read NGROK_TOKEN

# 设置 ngrok 授权令牌
sudo docker exec -it debian_container bash -c "ngrok config add-authtoken $NGROK_TOKEN"

# 启动 ngrok 临时隧道并映射容器的 22 端口
sudo docker exec -it debian_container bash -c "nohup ngrok tcp 22 &"

# 获取 ngrok 隧道地址
TUNNEL_URL=$(sudo docker exec -it debian_container bash -c "curl -s http://localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url'")

echo "容器已启动，SSH 密码为 'Meatbuns'。ngrok 隧道地址为: $TUNNEL_URL"
echo "您可以通过以下命令连接到容器："
echo "ssh root@$TUNNEL_URL -p 22"
