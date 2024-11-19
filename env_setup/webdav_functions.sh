# 删除 WebDAV 配置
delete_webdav_config() {
    echo "正在获取现有的 WebDAV 配置..."
    existing_configs=$(rclone listremotes)

    if [ -z "$existing_configs" ]; then
        echo "无配置文件，请先创建配置。"
        pause
        return
    fi

    echo "以下是当前的 WebDAV 配置："
    # 为每个配置添加序号
    echo "$existing_configs" | nl -w2 -s'. '  # 使用序号列出配置

    read -p "请输入要删除的 WebDAV 配置的序号: " choice

    # 获取选中的配置名称
    selected_config=$(echo "$existing_configs" | sed -n "${choice}p")

    # 检查输入的序号是否有效
    if [ -z "$selected_config" ]; then
        echo "无效的序号，请重试。"
        pause
        return
    fi

    echo "正在删除 WebDAV 配置 $selected_config..."
    rclone config delete "$selected_config"

    if [ $? -eq 0 ]; then
        echo "WebDAV 配置 $selected_config 已成功删除。"
    else
        echo "删除配置失败，请检查是否有权限或名称是否正确。"
    fi
    pause
}
