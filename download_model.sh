#!/bin/bash

# 模型下载脚本
set -e  # 遇到错误时退出脚本

echo "===== 开始设置模型下载环境 ====="

# 1. 安装必要依赖
echo -e "\n[1/3] 检查并安装系统依赖..."
if ! command -v git &> /dev/null || ! command -v git-lfs &> /dev/null; then
    echo "检测到需要安装git和git-lfs..."
    
    # 检测系统类型
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux系统
        sudo apt-get update
        sudo apt-get install -y git git-lfs
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS系统
        if ! command -v brew &> /dev/null; then
            echo "错误: 需要先安装Homebrew"
            exit 1
        fi
        brew install git git-lfs
    else
        echo "错误: 不支持的操作系统"
        exit 1
    fi
    
    # 初始化git-lfs
    git lfs install
else
    echo "依赖已安装(git和git-lfs)"
fi

# 2. 创建文件夹结构
echo -e "\n[2/3] 创建文件夹结构..."
MODEL_ROOT="$(pwd)/models"
mkdir -p "${MODEL_ROOT}/BAAI"
mkdir -p "${MODEL_ROOT}/SWHL"

# 3. 下载模型
echo -e "\n[3/3] 开始下载模型..."

# 下载BAAI模型
echo "下载BAAI模型..."
cd "${MODEL_ROOT}/BAAI"

echo "-> 下载bge-m3模型 (约2.3GB)..."
git clone https://hf-mirror.com/BAAI/bge-m3

echo "-> 下载bge-reranker-v2-m3模型 (约1.2GB)..."
git clone https://hf-mirror.com/BAAI/bge-reranker-v2-m3

# 下载RapidOCR模型
echo "下载RapidOCR模型..."
cd "${MODEL_ROOT}/SWHL"
git clone https://github.com/RapidAI/RapidOCR

# 返回初始目录
cd - > /dev/null

echo -e "\n===== 所有模型下载完成 ====="
echo "模型存放位置:"
echo "BAAI 模型: ${MODEL_ROOT}/BAAI/"
echo "RapidOCR: ${MODEL_ROOT}/SWHL/RapidOCR"
