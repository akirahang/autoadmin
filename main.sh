# 主菜单函数
show_main_menu() {
    while true; do
        clear
        echo "==============================="
        echo "      脚本功能列表       "
        echo "==============================="
        echo "1. Docker 管理"
        echo "2. 快速部署"
        echo "3. 系统优化"
        echo "4. 系统清理"
        echo "5. 添加 Cron 任务"
        echo "6. 删除 Cron 任务"
        echo "7. 列出 Cron 任务"
        echo "8. 退出"
        echo "==============================="
        read -p "请选择一个选项 (1-8): " choice

        case $choice in
            1)
                show_docker_menu
                ;;
            2)
                quick_deploy_menu
                ;;
            3)
                show_system_optimization_menu
                ;;
            4)
                show_system_cleanup_menu
                ;;
            5)
                add_cron_job
                ;;
            6)
                remove_cron_job
                ;;
            7)
                list_cron_jobs
                ;;
            8)
                echo "退出脚本"
                exit 0
                ;;
            *)
                echo "无效选项，请重试"
                sleep 2
                ;;
        esac
    done
}

# Docker 管理菜单
show_docker_menu() {
    while true; do
        clear
        echo "==============================="
        echo "      Docker 管理菜单       "
        echo "==============================="
        echo "1. 查看所有容器"
        echo "2. 启动容器"
        echo "3. 停止容器"
        echo "4. 删除容器"
        echo "5. 返回主菜单"
        echo "==============================="
        read -p "请选择一个选项 (1-5): " docker_choice

        case $docker_choice in
            1)
                docker ps -a
                read -p "按 Enter 键返回 Docker 管理菜单..."
                ;;
            2)
                read -p "请输入容器ID或名称： " container_id
                docker start "$container_id"
                echo "容器 $container_id 已启动"
                read -p "按 Enter 键返回 Docker 管理菜单..."
                ;;
            3)
                read -p "请输入容器ID或名称： " container_id
                docker stop "$container_id"
                echo "容器 $container_id 已停止"
                read -p "按 Enter 键返回 Docker 管理菜单..."
                ;;
            4)
                delete_container
                read -p "按 Enter 键返回 Docker 管理菜单..."
                ;;
            5)
                return
                ;;
            *)
                echo "无效选项，请重试"
                sleep 2
                ;;
        esac
    done
}

# 系统优化菜单
show_system_optimization_menu() {
    while true; do
        clear
        echo "==============================="
        echo "      系统优化菜单       "
        echo "==============================="
        echo "1. 启用 BBR FQ"
        echo "2. 修改 DNS 设置"
        echo "3. 调整交换空间大小"
        echo "4. 修改 /tmp 大小"
        echo "5. 返回主菜单"
        echo "==============================="
        read -p "请选择一个选项 (1-5): " optimization_choice

        case $optimization_choice in
            1)
                enable_bbr_fq
                read -p "按 Enter 键返回系统优化菜单..."
                ;;
            2)
                modify_dns_settings
                ;;
            3)
                adjust_swap_space
                ;;
            4)
                modify_tmp_size
                ;;
            5)
                return
                ;;
            *)
                echo "无效选项，请重试"
                sleep 2
                ;;
        esac
    done
}

# 系统清理菜单
show_system_cleanup_menu() {
    while true; do
        clear
        echo "==============================="
        echo "      系统清理菜单       "
        echo "==============================="
        echo "1. 更新并清理系统"
        echo "2. 清除容器日志"
        echo "3. 返回主菜单"
        echo "==============================="
        read -p "请选择一个选项 (1-3): " cleanup_choice

        case $cleanup_choice in
            1)
                update_and_clean_system
                read -p "按 Enter 键返回系统清理菜单..."
                ;;
            2)
                clear_container_logs
                read -p "按 Enter 键返回系统清理菜单..."
                ;;
            3)
                return
                ;;
            *)
                echo "无效选项，请重试"
                sleep 2
                ;;
        esac
    done
}

# 启动主菜单
show_main_menu
