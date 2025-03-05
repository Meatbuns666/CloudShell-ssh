#!/bin/bash

# 更新并安装依赖
echo "Updating and installing dependencies..."
apt update
apt install -y openssh-server sudo wget unzip

# 创建 SSH 所需的目录
echo "Creating SSH directories..."
mkdir /var/run/sshd

# 设置 root 密码为 Meatbuns
echo "Setting root password..."
echo "root:Meatbuns" | chpasswd

# 配置 SSH 允许密码认证
echo "Configuring SSH to allow password authentication..."
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
service ssh restart

# 安装 Ngrok
echo "Downloading and installing Ngrok..."
wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip
unzip ngrok-stable-linux-amd64.zip
chmod +x ngrok
mv ngrok /usr/local/bin/

# 启动 Ngrok 进行端口映射
echo "Starting Ngrok for SSH access..."
ngrok tcp 22 &

# 输出 Ngrok 生成的地址
echo "Ngrok is tunneling your SSH on port 22. You can connect using the following address:"
ngrok tcp 22 | tee /dev/null | tail -n 20
