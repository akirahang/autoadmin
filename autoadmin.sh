#!/bin/bash

# 设置仓库地址
REPO_URL="https://github.com/akirahang/autoadmin.git"

# 设置根目录下的目标文件夹名
TARGET_DIR="/root/autoadmin"  # 更正为 /root/autoadmin

# 切换到 root 用户的根目录
cd /root || { echo "无法切换到根目录"; exit 1; }

# 检查并删除现有的 autoadmin 文件夹
if [ -d "$TARGET_DIR" ]; then
    echo "文件夹 $TARGET_DIR 已存在，正在删除..."
    sudo rm -rf "$TARGET_DIR"
    echo "$TARGET_DIR 已删除"
fi

# 克隆仓库
echo "正在克隆仓库..."
git clone "$REPO_URL" || { echo "克隆仓库失败"; exit 1; }

# 进入 autoadmin 文件夹
cd "$TARGET_DIR" || { echo "进入 $TARGET_DIR 失败"; exit 1; }

# 确保 main.sh 存在并运行
if [ -f "main.sh" ]; then
    echo "正在运行 main.sh..."
    sudo ./main.sh
else
    echo "main.sh 文件不存在，无法运行"
    exit 1
fi
