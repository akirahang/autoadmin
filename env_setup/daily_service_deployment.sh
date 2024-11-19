#!/bin/bash

# 获取本机公网IP
get_public_ip() {
    public_ip=$(curl -s ifconfig.me)
    echo $public_ip
}

# 服务容器的配置
services=(
    "AdGuardHome - 广告过滤器"
    "Alist - 文件管理工具"
    "Calibre Web - 电子书管理工具"
    "qBittorrent - 下载工具"
    "Qinglong - 自动化脚本"
    "Vaultwarden - 密码管理"
    "Photoprism - 照片管理工具"
    "Vocechat - 聊天工具"
    "WordPress - 网站"
    "Synctv - 文件同步"
)

# 部署服务函数
deploy_service() {
    read -p "请输入要部署的服务序号: " service_index

    # 确保选择的序号有效
    if ! [[ "$service_index" =~ ^[0-9]+$ ]] || [ "$service_index" -lt 1 ] || [ "$service_index" -gt ${#services[@]} ]; then
        echo "无效的序号，请重新选择。"
        return
    fi

    # 获取选中的服务名称
    service_name="${services[$((service_index - 1))]}"
    echo "您选择的服务是: $service_name"

    case "$service_name" in
        "AdGuardHome - 广告过滤器")
            docker run -d --name adguardhome -p 53:53 -p 3000:3000 adguard/adguardhome
            echo "AdGuardHome 服务已部署，访问地址：http://$(get_public_ip):3000"
            ;;
        "Alist - 文件管理工具")
            docker run -d --name alist -p 5244:5244 -p 6800:6800 xhofe/alist-aria2
            echo "Alist 服务已部署，访问地址：http://$(get_public_ip):5244"
            ;;
        "Calibre Web - 电子书管理工具")
            docker run -d --name calibre-web -p 8083:8083 lscr.io/linuxserver/calibre-web
            echo "Calibre Web 服务已部署，访问地址：http://$(get_public_ip):8083"
            ;;
        "qBittorrent - 下载工具")
            docker run -d --name qbittorrent -p 8080:8080 -p 6881:6881 lscr.io/linuxserver/qbittorrent
            echo "qBittorrent 服务已部署，访问地址：http://$(get_public_ip):8080"
            ;;
        "Qinglong - 自动化脚本")
            docker run -d --name qinglong -p 5700:5700 whyour/qinglong
            echo "Qinglong 服务已部署，访问地址：http://$(get_public_ip):5700"
            ;;
        "Vaultwarden - 密码管理")
            # 提示用户输入数据库相关信息
            read -p "请输入 Vaultwarden 数据库用户名: " db_user
            read -sp "请输入 Vaultwarden 数据库密码: " db_password
            echo ""
            read -p "请输入数据库的主机 IP (默认为本机 IP): " db_host
            db_host="${db_host:-$(get_public_ip)}"  # 默认使用本机 IP
            
            # 启动 Vaultwarden 服务
            docker run -d --name vaultwarden -p 86:80 \
                -e DATABASE_URL=postgresql://$db_user:$db_password@$db_host:5432/vaultwarden_db \
                vaultwarden/server:latest
            echo "Vaultwarden 服务已部署，访问地址：http://$(get_public_ip):86"
            ;;
        "Photoprism - 照片管理工具")
            docker run -d --name photoprism -p 2342:2342 photoprism/photoprism
            echo "Photoprism 服务已部署，访问地址：http://$(get_public_ip):2342"
            ;;
        "Vocechat - 聊天工具")
            docker run -d --name vocechat -p 3019:3000 privoce/vocechat-server:latest
            echo "Vocechat 服务已部署，访问地址：http://$(get_public_ip):3019"
            ;;
        "WordPress - 网站")
            docker run -d --name wordpress -p 8089:80 wordpress
            echo "WordPress 服务已部署，访问地址：http://$(get_public_ip):8089"
            ;;
        "Synctv - 文件同步")
            docker run -d --name synctv -p 8092:8080 synctvorg/synctv:latest
            echo "Synctv 服务已部署，访问地址：http://$(get_public_ip):8092"
            ;;
        *)
            echo "未知服务，请重新选择。"
            ;;
    esac
}

# 显示服务列表
show_services_list() {
    echo "==============================="
    echo "请选择要部署的服务："
    for i in "${!services[@]}"; do
        echo "$((i + 1)). ${services[i]}"
    done
    echo "==============================="
}

# 部署服务主函数
daily_service_deployment_menu() {
    while true; do
        clear
        show_services_list
        read -p "请输入服务的序号 (或输入 0 退出): " service_choice

        if [[ "$service_choice" == "0" ]]; then
            echo "退出部署菜单"
            break
        elif [[ "$service_choice" =~ ^[0-9]+$ ]] && [ "$service_choice" -ge 1 ] && [ "$service_choice" -le ${#services[@]} ]; then
            deploy_service "$service_choice"
        else
            echo "无效选择，请重新输入"
        fi
        sleep 2
    done
}

# 启动部署菜单
daily_service_deployment_menu
