#!/bin/bash

source ./utils.sh

clear
echo "==========================="
echo "Ubuntu服务器运维脚本"
echo "==========================="
echo "1. 部署 Docker"
echo "2. 开启 BBR"
echo "3. 安装基础环境"
echo "4. 退出"
echo "==========================="
read -p "请输入选择 (1-4): " choice

case $choice in
    1)
        ./docker_deploy.sh
        ;;
    2)
        ./enable_bbr.sh
        ;;
    3)
        ./install_env.sh
        ;;
    4)
        echo "退出脚本"
        exit 0
        ;;
    *)
        echo "无效选择，请重新输入"
        ;;
esac
