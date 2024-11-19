#!/bin/bash

# NPS 安装和配置
install_nps() {
    echo "开始安装 NPS..."
    
    # 设置 NPS 项目路径
    NPS_DIR="/root/nps"

    # 检查 Docker 是否已安装
    command -v docker >/dev/null 2>&1 || { echo "请先安装 Docker"; exit 1; }

    # 克隆 NPS 项目
    mkdir -p "$NPS_DIR"
    cd "$NPS_DIR"
    git clone https://github.com/ehang-io/nps.git . || { echo "克隆 NPS 代码失败"; exit 1; }

    # 交互式获取配置参数
    read -p "请输入 http_proxy_port 的值: " http_proxy_port
    read -p "请输入 https_proxy_port 的值: " https_proxy_port
    read -p "请输入 web_username 的值: " web_username
    read -p "请输入 web_password 的值: " web_password
    read -p "请输入 web_ip 的值: " web_ip
    read -p "请输入 auth_crypt_key 的值: " auth_crypt_key

    # 修改配置文件
    sed -i "s/^http_proxy_port=.*$/http_proxy_port=${http_proxy_port}/" conf/nps.conf
    sed -i "s/^https_proxy_port=.*$/https_proxy_port=${https_proxy_port}/" conf/nps.conf
    sed -i "s/^web_username=.*$/web_username=${web_username}/" conf/nps.conf
    sed -i "s/^web_password=.*$/web_password=${web_password}/" conf/nps.conf
    sed -i "s/^web_ip=.*$/web_ip=${web_ip}/" conf/nps.conf
    sed -i "s/^auth_crypt_key=.*$/auth_crypt_key=${auth_crypt_key}/" conf/nps.conf

    # 运行 Docker 容器
    docker run -d --name nps --net=host -v "$NPS_DIR/conf":/conf --restart=always npscn/nps || { echo "启动 NPS 容器失败"; exit 1; }

    echo "NPS 容器已启动，请访问 http://你的IP:8080 进行管理"
}

# WireGuard-Easy 安装和配置
install_wireguard_easy() {
    echo "开始安装 WireGuard-Easy..."
    
    # 交互式获取配置参数
    read -p "请输入公网 IP: " WG_HOST
    read -p "请输入 WireGuard 管理账户密码: " WG_PASSWORD
    read -p "请输入 WireGuard 服务端口 (默认 51820): " WG_PORT
    WG_PORT=${WG_PORT:-51820}

    # 创建 WireGuard-Easy 配置目录
    mkdir -p /root/wireguard

    # 创建 Docker Compose 配置文件
    cat > /root/wireguard/docker-compose.yml <<EOF
version: '3.3'
services:
  wg-easy:
    image: ghcr.io/wg-easy/wg-easy
    container_name: wg-easy
    environment:
      - WG_HOST=${WG_HOST}
      - PASSWORD=${WG_PASSWORD}
      - WG_PORT=${WG_PORT}
    volumes:
      - /root/wireguard:/etc/wireguard
    ports:
      - 51822:51820/udp
      - 51821:51821/tcp
    restart: unless-stopped
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    sysctls:
      - net.ipv4.ip_forward=1
      - net.ipv4.conf.all.src_valid_mark=1
EOF

    # 运行 WireGuard-Easy Docker 容器
    cd /root/wireguard
    docker-compose up -d || { echo "启动 WireGuard-Easy 容器失败"; exit 1; }

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

# 主菜单
main_menu() {
    while true; do
        clear
        echo "==============================="
        echo "      系统管理功能菜单         "
        echo "==============================="
        echo "1. 内网端口转发管理"
        echo "2. 退出"
        echo "==============================="
        read -p "请选择一个选项 (1-2): " choice

        case $choice in
            1) port_forwarding_menu ;;  # 进入内网端口转发管理菜单
            2) exit 0 ;;                # 退出
            *) echo "无效选项，请重试"; sleep 2 ;;
        esac
    done
}

# 启动主菜单
main_menu
