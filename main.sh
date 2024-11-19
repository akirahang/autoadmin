#!/bin/bash

# 导入功能函数
source functions.sh

# 主菜单函数
show_main_menu() {
    while true; do
        clear
        echo "==============================="
        echo "      脚本功能列表       "
        echo "==============================="
        echo "1. Docker 管理"
        echo "2. 快速部署"
        echo "3. 系统维护"
        echo "4. Cron 任务管理"
        echo "5. WebDAV 挂载"
        echo "6. 退出"
        echo "==============================="
        read -p "请选择一个选项 (1-6): " choice

        case $choice in
            1) show_docker_menu ;;
            2) quick_deploy_menu ;;
            3) system_maintenance_menu ;;
            4) cron_task_menu ;;
            5) mount_webdav_menu ;;
            6) echo "退出脚本"; exit 0 ;;
            *) echo "无效选项，请重试"; sleep 2 ;;
        esac
    done
}

# 启动主菜单
show_main_menu
