#!/bin/bash

# 更新系统并安装所需工具
sudo apt update
sudo apt install -y wget unzip curl jq

# 拉取 Debian 12 镜像
sudo docker pull debian:12

# 创建并启动一个新的 Debian 容器（确保容器持续运行）
sudo docker run -d --name debian_container -p 2222:22 debian:12 tail -f /dev/null

# 进入容器并安装 SSH 服务和其他必需工具
sudo docker exec -it debian_container bash -c "apt update && apt install -y openssh-server sudo wget unzip curl jq"

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

# 启动 ngrok 临时隧道并映射容器的 22 端口
sudo docker exec -it debian_container bash -c "nohup ngrok tcp 2222 &"

# 等待几秒钟以便 ngrok 启动
sleep 5

# 提取 ngrok 隧道的公网地址和端口
TUNNEL_URL=$(sudo docker exec -it debian_container bash -c "curl -s http://127.0.0.1:4040/api/tunnels | jq -r '.tunnels[0].public_url'")
TUNNEL_PORT=$(echo $TUNNEL_URL | sed 's/tcp:\/\///' | cut -d ':' -f2)

# 输出隧道信息
echo "容器已启动，SSH 密码为 'Meatbuns'。ngrok 隧道地址为: $TUNNEL_URL"
echo "您可以通过以下命令连接到容器："
echo "ssh root@$TUNNEL_URL -p $TUNNEL_PORT"
