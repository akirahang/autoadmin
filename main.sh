#!/bin/bash

# 引用 functions.sh 和 docker_functions.sh
source ./functions.sh
source ./docker_functions.sh

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
        echo "5. 退出"
        echo "==============================="
        read -p "请选择一个选项 (1-5): " choice

        case $choice in
            1) show_docker_menu ;;
            2) system_maintenance_menu ;;
            3) cron_task_menu ;;
            4) mount_webdav_menu ;;
            5) echo "退出脚本"; exit 0 ;;
            *) echo "无效选项，请重试"; sleep 2 ;;
        esac
    done
}

# 启动主菜单
show_main_menu
