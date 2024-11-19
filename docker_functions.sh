#!/bin/bash

# 查看所有容器
list_all_containers() {
    echo "正在获取所有容器的状态..."
    docker ps -a
}

# 启动指定容器
start_container() {
    read -p "请输入容器ID或名称： " container_id
    if docker start "$container_id"; then
        echo "容器 $container_id 已成功启动！"
    else
        echo "启动容器 $container_id 失败，请检查容器是否存在或输入正确。"
    fi
}

# 停止指定容器
stop_container() {
    read -p "请输入容器ID或名称： " container_id
    if docker stop "$container_id"; then
        echo "容器 $container_id 已成功停止！"
    else
        echo "停止容器 $container_id 失败，请检查容器是否存在或输入正确。"
    fi
}

# 删除指定容器以及相关卷和挂载目录
delete_container() {
    read -p "请输入容器ID或名称： " container_id
    
    # 确认是否删除与之相关的挂载目录和卷
    read -p "您是否希望删除该容器的卷以及相关映射目录？(y/n): " confirm
    if [ "$confirm" != "y" ]; then
        echo "已取消删除操作。"
        return
    fi

    # 获取容器详细信息，包括绑定挂载目录
    container_info=$(docker inspect "$container_id" 2>/dev/null)
    if [ $? -ne 0 ]; then
        echo "无法找到容器 $container_id，请检查输入是否正确。"
        return
    fi

    # 删除容器挂载的主机目录（bind mounts）
    echo "正在尝试删除容器挂载的本地目录..."
    bind_mounts=$(echo "$container_info" | jq -r '.[].Mounts[] | select(.Type=="bind") | .Source')
    if [ -n "$bind_mounts" ]; then
        for mount in $bind_mounts; do
            if [ -d "$mount" ]; then
                rm -rf "$mount"
                echo "已删除挂载目录：$mount"
            else
                echo "挂载目录不存在或已被删除：$mount"
            fi
        done
    else
        echo "未检测到挂载目录。"
    fi

    # 删除容器以及关联卷
    echo "正在删除容器和关联卷..."
    if docker rm -v "$container_id"; then
        echo "容器 $container_id 和关联卷已成功删除！"
    else
        echo "删除容器失败，请检查输入是否正确或容器状态。"
    fi
}

# 调用 Docker 菜单功能
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
                list_all_containers
                read -p "按 Enter 键返回 Docker 管理菜单..."
                ;;
            2)
                start_container
                read -p "按 Enter 键返回 Docker 管理菜单..."
                ;;
            3)
                stop_container
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

# 启动主菜单
show_main_menu

