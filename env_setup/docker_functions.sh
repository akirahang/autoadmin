#!/bin/bash

# WebDAV 配置路径
WEBDAV_CONFIG_PATH="/root/.config/rclone/rclone.conf"
WEBDAV_REMOTE="webdav_remote"  # 默认的 WebDAV 远程配置名称

# 检查 rclone 是否安装
check_rclone_installed() {
    if ! command -v rclone &> /dev/null; then
        echo "未检测到 rclone，请安装 rclone。"
        return 1
    fi
    echo "rclone 已安装"
    return 0
}

# 获取 WebDAV 配置
get_webdav_configs() {
    rclone config show | grep -i "webdav" -B 3
}

# 选择 WebDAV 配置
choose_webdav_config() {
    # 获取 WebDAV 配置
    webdav_configs=$(rclone config show | grep -i "webdav" -B 3 | grep "name" | awk '{print $2}')

    # 如果没有 WebDAV 配置
    if [ -z "$webdav_configs" ]; then
        echo "未检测到 WebDAV 配置，请创建 WebDAV 配置。"
        return 1
    fi

    # 如果只有一个 WebDAV 配置，直接使用该配置
    if [ $(echo "$webdav_configs" | wc -l) -eq 1 ]; then
        selected_config=$(echo "$webdav_configs" | head -n 1)
        echo "只有一个 WebDAV 配置，自动选择：$selected_config"
        WEBDAV_REMOTE="$selected_config"
        return 0
    fi

    # 如果有多个配置，提供交互式选择
    echo "检测到多个 WebDAV 配置，请选择一个："
    select config in $webdav_configs; do
        if [ -n "$config" ]; then
            WEBDAV_REMOTE="$config"
            echo "您选择的 WebDAV 配置是：$config"
            break
        else
            echo "无效的选择，请重新选择。"
        fi
    done
}

# 容器备份到 WebDAV
backup_container_to_webdav() {
    # 确保 rclone 已安装
    check_rclone_installed || exit 1

    # 选择 WebDAV 配置
    choose_webdav_config || exit 1

    # 获取要备份的容器信息
    echo "请选择要备份的容器："
    containers=($(docker ps -a -q))
    if [ ${#containers[@]} -eq 0 ]; then
        echo "没有找到任何容器。"
        exit 1
    fi

    # 列出所有容器
    for i in "${!containers[@]}"; do
        container_id="${containers[i]}"
        container_name=$(docker inspect --format '{{.Name}}' "$container_id" | sed 's/^\///')  # 获取容器名称
        echo "$((i + 1)). ID: $container_id 名称: $container_name"
    done

    read -p "请输入要备份的容器序号: " container_index
    if ! [[ "$container_index" =~ ^[0-9]+$ ]] || [ "$container_index" -le 0 ] || [ "$container_index" -gt ${#containers[@]} ]; then
        echo "无效的选择，请重试。"
        exit 1
    fi

    container_id="${containers[$((container_index - 1))]}"
    container_name=$(docker inspect --format '{{.Name}}' "$container_id" | sed 's/^\///')  # 获取容器名称
    echo "您选择的容器是：ID: $container_id 名称: $container_name"

    # 获取容器的挂载目录
    echo "正在列出容器的挂载目录..."
    mounts=$(docker inspect "$container_id" | jq -r '.[].Mounts[] | select(.Type=="bind") | .Source')
    if [ -z "$mounts" ]; then
        echo "容器没有映射的目录"
        exit 1
    fi

    # WebDAV 备份路径
    read -p "请输入 WebDAV 备份路径 (例如 /backup/): " webdav_path

    # 遍历所有挂载目录进行备份
    for mount_dir in $mounts; do
        if [ -d "$mount_dir" ]; then
            echo "正在备份目录 $mount_dir 到 WebDAV..."
            rclone copy "$mount_dir" "$WEBDAV_REMOTE:$webdav_path" --progress || {
                echo "备份失败，请检查网络或配置。"
                exit 1
            }
            echo "备份完成：$mount_dir -> $WEBDAV_REMOTE:$webdav_path"
        else
            echo "目录 $mount_dir 不存在，跳过备份。"
        fi
    done
}

# 设置定期备份任务
set_scheduled_backup() {
    # 获取容器信息
    containers=($(docker ps -a -q))
    if [ ${#containers[@]} -eq 0 ]; then
        echo "没有找到任何容器。"
        exit 1
    fi

    echo "请选择要备份的容器："
    for i in "${!containers[@]}"; do
        container_id="${containers[i]}"
        container_name=$(docker inspect --format '{{.Name}}' "$container_id" | sed 's/^\///')
        echo "$((i + 1)). ID: $container_id 名称: $container_name"
    done

    read -p "请输入要备份的容器序号: " container_index
    if ! [[ "$container_index" =~ ^[0-9]+$ ]] || [ "$container_index" -le 0 ] || [ "$container_index" -gt ${#containers[@]} ]; then
        echo "无效的选择，请重试。"
        exit 1
    fi

    container_id="${containers[$((container_index - 1))]}"
    container_name=$(docker inspect --format '{{.Name}}' "$container_id" | sed 's/^\///')

    # 获取容器的挂载目录
    mounts=$(docker inspect "$container_id" | jq -r '.[].Mounts[] | select(.Type=="bind") | .Source')
    if [ -z "$mounts" ]; then
        echo "容器没有映射的目录"
        exit 1
    fi

    # WebDAV 备份路径
    read -p "请输入 WebDAV 备份路径 (例如 /backup/): " webdav_path

    # 定期备份时间（例如每天凌晨3点备份）
    read -p "请输入定期备份时间 (cron 格式，例如：0 3 * * * 表示每天凌晨 3 点): " cron_time

    # 添加 Cron 任务
    for mount_dir in $mounts; do
        if [ -d "$mount_dir" ]; then
            echo "$cron_time root rclone copy $mount_dir $WEBDAV_REMOTE:$webdav_path --progress" >> /etc/cron.d/container_backup
        fi
    done
    echo "定期备份任务已设置。"
}

# 删除定期备份任务
delete_scheduled_backup() {
    echo "正在列出当前的定期备份任务..."
    crontab -l | grep -i "rclone copy" || {
        echo "没有找到定期备份任务。"
        return
    }

    read -p "请输入要删除的定期备份任务的行号: " task_number
    crontab -l | sed "${task_number}d" | crontab -
    echo "定期备份任务已删除。"
}

# 主菜单
main_menu() {
    while true; do
        clear
        echo "==============================="
        echo "      Docker 管理菜单       "
        echo "==============================="
        echo "1. 查看所有容器"
        echo "2. 启动容器"
        echo "3. 停止容器"
        echo "4. 删除容器"
        echo "5. 容器立即备份到 WebDAV"
        echo "6. 设置定期备份"
        echo "7. 删除定期备份任务"
        echo "8. 退出"
        echo "==============================="
        read -p "请选择一个选项 (1-8): " docker_choice

        case $docker_choice in
            1) list_all_containers ;;
            2) manage_docker_container start ;;
            3) manage_docker_container stop ;;
            4) manage_docker_container remove ;;
            5) backup_container_to_webdav ;;
            6) set_scheduled_backup ;;
            7) delete_scheduled_backup ;;
            8) exit 0 ;;
            *) echo "无效选项，请重新选择。" ;;
        esac
    done
}

main_menu
