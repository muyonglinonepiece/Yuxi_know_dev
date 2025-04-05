#!/bin/bash

# Docker安装脚本
# 包含NVIDIA Docker支持

set -e  # 如果任何命令失败，则退出脚本

echo "正在更新软件包列表..."
sudo apt-get update

echo "正在安装依赖包..."
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

echo "添加Docker官方GPG密钥..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

echo "添加Docker仓库..."
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

echo "再次更新软件包列表..."
sudo apt-get update

echo "安装Docker CE..."
sudo apt-get install -y docker-ce

echo "添加NVIDIA Docker仓库..."
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
    && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - \
    && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

echo "安装nvidia-docker2..."
sudo apt-get update
sudo apt-get install -y nvidia-docker2

echo "重启Docker服务..."
sudo systemctl restart docker

echo "安装完成！"
echo "运行以下命令测试nvidia-docker是否正常工作:"
echo "sudo docker run --gpus all nvidia/cuda:11.0-base nvidia-smi"
