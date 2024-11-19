#!/bin/bash

# 引用 functions.sh、docker_functions.sh 和 crontab.sh 等文件
. ./env_setup/functions.sh
. ./env_setup/docker_functions.sh
. ./env_setup/crontab.sh
. ./env_setup/vpn_functions.sh
. ./env_setup/webdav_functions.sh
. ./env_setup/port_forwarding.sh

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
        echo "6. 内网端口转发管理"
        echo "7. 退出"
        echo "==============================="
        read -p "请选择一个选项 (1-7): " choice
        echo "选择的选项是: $choice"  # 调试输出，查看选择的内容

        case $choice in
            1) echo "进入 Docker 管理"; show_docker_menu ;;      # Docker 管理菜单
            2) echo "进入 系统维护"; system_maintenance_menu ;;  # 系统维护菜单
            3) echo "进入 Cron 任务管理"; cron_task_menu ;;      # Cron 任务管理
            4) echo "进入 WebDAV 挂载"; mount_webdav_menu ;;     # WebDAV 挂载
            5) echo "进入 科学上网管理"; vpn_menu ;;             # 科学上网管理
            6) echo "进入 内网端口转发管理"; port_forwarding_menu ;; # 内网端口转发管理菜单
            7) echo "退出脚本"; exit 0 ;;                         # 退出脚本
            *) echo "无效选项，请重试"; sleep 2 ;;               # 无效选项提示
        esac
    done
}

# 启动主菜单
show_main_menu
