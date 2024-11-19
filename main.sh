#!/bin/bash
# 引用 functions.sh、docker_functions.sh 和 crontab.sh
source ./env_setup/functions.sh
source ./env_setup/docker_functions.sh
source ./env_setup/crontab.sh
source ./env_setup/vpn_functions.sh
source ./env_setup/webdav_functions.sh
source ./env_setup/port_forwarding.sh
# 主菜单函数
show_main_menu() {
    while true; do
        clear
        echo "==============================="
        echo "      脚本功能列表       "
        echo "==============================="
        echo "1. Docker 管理"
        echo "2. 系统维护"
        echo "3. Cron 任务管理"
        echo "4. WebDAV 挂载"
        echo "5. 科学上网管理"
        echo "6. 内网穿透管理"            # 新增内网穿透管理选项
        echo "7. 退出"
        echo "==============================="
        read -p "请选择一个选项 (1-7): " choice

        case $choice in
            1) show_docker_menu ;;          # Docker 管理菜单
            2) system_maintenance_menu ;;   # 系统维护菜单
            3) cron_task_menu ;;            # Cron 任务管理
            4) mount_webdav_menu ;;         # WebDAV 挂载
            5) vpn_menu ;;                  # 科学上网管理
            6) port_forwarding_menu ;;        # 内网穿透管理菜单
            7) echo "退出脚本"; exit 0 ;;   # 退出脚本
            *) echo "无效选项，请重试"; sleep 2 ;;
        esac
    done
}
