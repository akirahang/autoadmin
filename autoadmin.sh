#!/bin/bash

# 设置仓库地址
REPO_URL="https://github.com/akirahang/autoadmin.git"

# 设置根目录下的目标文件夹名
TARGET_DIR="/autoadmin"

# 切换到 root 用户的根目录
cd /root

# 检查并删除现有的 autoadmin 文件夹
if [ -d "$TARGET_DIR" ]; then
    echo "文件夹 $TARGET_DIR 已存在，正在删除..."
    sudo rm -rf "$TARGET_DIR"
    echo "$TARGET_DIR 已删除"
fi

# 克隆仓库
echo "正在克隆仓库..."
git clone "$REPO_URL"

# 进入 autoadmin 文件夹
cd "$TARGET_DIR" || { echo "进入 $TARGET_DIR 失败"; exit 1; }

# 运行 main.sh
echo "正在运行 main.sh..."
sudo ./main.sh

