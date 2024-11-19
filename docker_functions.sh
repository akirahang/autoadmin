#!/bin/bash

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
            1) list_all_containers ;;
            2) manage_docker_container start ;;
            3) manage_docker_container stop ;;
            4) manage_docker_container delete ;;
            5) return ;;
            *) echo "无效选项，请重试"; sleep 2 ;;
        esac
    done
}

# 列出所有容器
list_all_containers() {
    docker ps -a
    pause
}

# 管理 Docker 容器
manage_docker_container() {
    local action=$1
    read -p "请输入容器ID或名称: " container_id
    case $action in
        start)
            docker start "$container_id" && echo "容器 $container_id 已启动" ;;
        stop)
            docker stop "$container_id" && echo "容器 $container_id 已停止" ;;
        delete)
            delete_container "$container_id" ;;
    esac
    pause
}

# 删除容器及挂载目录和卷
delete_container() {
    local container_id=$1
    read -p "是否删除挂载目录和卷 (y/n): " confirm
    if [ "$confirm" = "y" ]; then
        docker inspect "$container_id" | jq -r '.[].Mounts[] | select(.Type=="bind") | .Source' | while read -r mount; do
            if [ -d "$mount" ]; then
                rm -rf "$mount" && echo "已删除挂载目录：$mount"
            fi
        done
    fi
    docker rm -v "$container_id" && echo "容器 $container_id 已删除" || echo "删除失败"
}

# 暂停等待用户按键
pause() {
    read -p "按 Enter 键继续..."
}
