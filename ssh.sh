#!/bin/bash

# 安装 wget 和 unzip
sudo apt install -y wget unzip

# 拉取 Debian 12 镜像
sudo docker pull debian:12

# 创建并启动一个新的 Debian 容器，映射 2222 端口到 22 端口
sudo docker run -d --name debian_container -p 2222:22 debian:12

# 进入容器并安装 SSH 服务
sudo docker exec -it debian_container bash -c "apt update && apt install -y openssh-server sudo"

# 设置 SSH 密码为 Meatbuns
sudo docker exec -it debian_container bash -c "echo 'root:Meatbuns' | chpasswd"

# 启动 SSH 服务
sudo docker exec -it debian_container bash -c "service ssh start"

# 安装 ngrok
sudo docker exec -it debian_container bash -c "wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip"
sudo docker exec -it debian_container bash -c "unzip ngrok-stable-linux-amd64.zip"
sudo docker exec -it debian_container bash -c "mv ngrok /usr/local/bin/"

# 提示用户输入 ngrok 授权令牌
echo "请输入您的 ngrok 授权令牌："
read NGROK_TOKEN

# 设置 ngrok 授权令牌
sudo docker exec -it debian_container bash -c "ngrok authtoken $NGROK_TOKEN"

# 启动 ngrok 临时隧道并映射容器的 2222 端口
sudo docker exec -it debian_container bash -c "nohup ngrok tcp 2222 &"

# 获取 ngrok 隧道的公网地址
sleep 5  # 等待 ngrok 启动
TUNNEL_URL=$(sudo docker exec -it debian_container bash -c "curl -s http://127.0.0.1:4040/api/tunnels | jq -r '.tunnels[0].public_url'")

# 提取动态端口号
TUNNEL_PORT=$(echo $TUNNEL_URL | sed 's/.*://')

# 输出隧道信息
echo "容器已启动，SSH 密码为 'Meatbuns'。ngrok 隧道地址为: $TUNNEL_URL"
echo "您可以通过以下命令连接到容器："
echo "ssh root@$TUNNEL_URL -p $TUNNEL_PORT"
