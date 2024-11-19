#!/bin/bash

# 生产环境部署功能模块

# 部署 Nginx 服务
deploy_nginx() {
    echo "开始部署 Nginx..."
    docker run -d --name nginx \
        -p 80:80 -p 443:443 \
        -v /root/nginx/conf:/etc/nginx/conf.d \
        -v /root/nginx/logs:/var/log/nginx \
        -v /root/nginx/html:/usr/share/nginx/html \
        --restart unless-stopped nginx || { echo "Nginx 部署失败"; exit 1; }
    echo "Nginx 部署完成！"
    pause
}

# 部署 MySQL 服务
deploy_mysql() {
    echo "开始部署 MySQL..."
    read -p "请输入 MySQL root 密码: " MYSQL_ROOT_PASSWORD
    docker run -d --name mysql \
        -p 3306:3306 \
        -v /root/mysql/data:/var/lib/mysql \
        -v /root/mysql/conf:/etc/mysql/conf.d \
        -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD \
        --restart unless-stopped mysql:8.0 || { echo "MySQL 部署失败"; exit 1; }
    echo "MySQL 部署完成！"
    pause
}

# 部署 Redis 服务
deploy_redis() {
    echo "开始部署 Redis..."
    docker run -d --name redis \
        -p 6379:6379 \
        -v /root/redis/data:/data \
        --restart unless-stopped redis:latest || { echo "Redis 部署失败"; exit 1; }
    echo "Redis 部署完成！"
    pause
}

# 生产环境部署菜单
production_deployment_menu() {
    while true; do
        clear
        echo "==============================="
        echo "    生产环境部署功能菜单       "
        echo "==============================="
        echo "1. 部署 Nginx"
        echo "2. 部署 MySQL"
        echo "3. 部署 Redis"
        echo "4. 返回主菜单"
        echo "==============================="
        read -p "请选择一个选项 (1-4): " choice

        case $choice in
            1) deploy_nginx ;;   # 部署 Nginx 服务
            2) deploy_mysql ;;   # 部署 MySQL 服务
            3) deploy_redis ;;   # 部署 Redis 服务
            4) return ;;         # 返回主菜单
            *) echo "无效选项，请重试"; sleep 2 ;;
        esac
    done
}

# 暂停等待用户操作
pause() {
    read -p "按 Enter 键继续..."
}
