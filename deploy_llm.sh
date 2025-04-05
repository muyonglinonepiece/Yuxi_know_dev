#!/bin/bash

# LLM 开发环境部署脚本
# 功能：启动容器、配置环境、下载模型、启动vLLM服务

set -e  # 如果任何命令失败，则退出脚本

# 1. 启动容器
echo "正在启动LLM开发容器..."
docker run -d --name llm_dev --network host -p 8099:8099 --gpus all -v /datad:/datad -it pytorch/pytorch:2.6.0-cuda12.4-cudnn9-devel /bin/bash

# 2. 配置容器环境
echo "正在配置容器环境..."
docker exec llm_dev bash -c '
    # 设置清华源
    echo "设置pip清华源..."
    pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
    pip config set install.trusted-host pypi.tuna.tsinghua.edu.cn

    # 安装依赖
    echo "安装vllm和bitsandbytes..."
    pip install vllm
    pip install "bitsandbytes>=0.45.0"
'

# 3. 下载模型
echo "正在下载模型..."
docker exec llm_dev bash -c '
    mkdir -p /datad/models/
    cd /datad/models/
    echo "开始下载模型，这可能需要较长时间..."
    modelscope download --model mlx-community/DeepSeek-R1-Distill-Qwen-7B-8bit --local_dir ./
'

# 4. 启动服务
echo "正在启动vLLM服务..."
docker exec -d llm_dev bash -c '
    cd /datad/models/
    vllm serve /datad/models/DeepSeek-R1-Distill-Qwen-7B-bnb-4bit \
        --tensor-parallel-size 1 \
        --max-model-len 16384 \
        --served-model-name deepseek \
        --enforce-eager \
        --host 0.0.0.0 \
        --port 8099 \
        --dtype=half \
        --load_format bitsandbytes \
        --quantization bitsandbytes \
        --enable-reasoning \
        --reasoning-parser deepseek_r1
'

echo "部署完成！"
echo "vLLM服务已启动，监听端口: 8099"
echo "您可以使用以下命令进入容器:"
echo "  docker exec -it llm_dev bash"
echo ""
echo "要停止服务，可以使用:"
echo "  docker stop llm_dev"
echo "要删除容器，可以使用:"
echo "  docker rm llm_dev"
