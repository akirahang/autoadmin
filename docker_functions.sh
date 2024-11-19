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
        echo "5. 快速部署云服务"
        echo "6. 返回主菜单"
        echo "==============================="
        read -p "请选择一个选项 (1-6): " docker_choice

        case $docker_choice in
            1) list_all_containers ;;
            2) manage_docker_container start ;;
            3) manage_docker_container stop ;;
            4) manage_docker_container delete ;;
            5) deploy_cloud_service ;;
            6) return ;;
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

# 快速部署云服务
deploy_cloud_service() {
    local compose_url="https://raw.githubusercontent.com/akirahang/autoadmin/refs/heads/main/docker_compose.yaml"
    local compose_file="/tmp/docker_compose.yaml"

    echo "正在下载配置文件..."
    curl -fsSL "$compose_url" -o "$compose_file" || { echo "配置文件下载失败，请检查链接。"; pause; return; }

    echo "配置文件已成功下载到 $compose_file"
    echo "正在解析服务列表..."

    # 提取服务名称
    mapfile -t services < <(yq e '.services | keys | .[]' "$compose_file")
    if [ ${#services[@]} -eq 0 ]; then
        echo "未检测到任何服务，请检查配置文件内容。"
        pause
        return
    fi

    echo "以下是可用的服务列表："
    for i in "${!services[@]}"; do
        echo "$((i + 1)). ${services[i]}"
    done

    read -p "请选择要部署的服务序号: " service_index
    if ! [[ "$service_index" =~ ^[0-9]+$ ]] || [ "$service_index" -le 0 ] || [ "$service_index" -gt ${#services[@]} ]; then
        echo "无效的选择，请重试。"
        pause
        return
    fi

    selected_service=${services[$((service_index - 1))]}
    echo "正在部署服务: $selected_service"

    # 部署选定服务
    docker compose -f "$compose_file" up -d "$selected_service" 2>/tmp/docker_error.log
    if [ $? -eq 0 ]; then
        echo "服务 $selected_service 部署成功。"
        echo "服务端口："
        docker inspect "$selected_service" | jq -r '.[].NetworkSettings.Ports | to_entries[] | "\(.key) -> \(.value[0].HostPort)"'
    else
        echo "服务部署失败。错误信息如下："
        cat /tmp/docker_error.log
    fi
    pause
}

# 暂停等待用户按键
pause() {
    read -p "按 Enter 键继续..."
}
