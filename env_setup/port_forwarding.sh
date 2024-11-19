#!/bin/bash

# NPS 安装和配置
install_nps() {
    echo "开始安装 NPS..."
    # NPS 安装步骤（假设使用 Docker 部署）
    docker pull npscn/nps
    docker run -d --name nps -p 443:443 npscn/nps
    echo "NPS 安装完成！"
}

# WireGuard-Easy 安装和配置
install_wireguard_easy() {
    echo "开始安装 WireGuard-Easy..."
    # WireGuard-Easy 安装步骤
    git clone https://github.com/ComplexString/wireguard-easy.git
    cd wireguard-easy
    ./install.sh
    echo "WireGuard-Easy 安装完成！"
}

# 内网端口转发管理菜单
port_forwarding_menu() {
    while true; do
        clear
        echo "==============================="
        echo "      内网端口转发功能菜单     "
        echo "==============================="
        echo "1. 安装 NPS"
        echo "2. 安装 WireGuard-Easy"
        echo "3. 返回主菜单"
        echo "==============================="
        read -p "请选择一个选项 (1-3): " choice

        case $choice in
            1) install_nps ;;              # 安装 NPS
            2) install_wireguard_easy ;;   # 安装 WireGuard-Easy
            3) return ;;                   # 返回主菜单
            *) echo "无效选项，请重试"; sleep 2 ;;
        esac
    done
}

