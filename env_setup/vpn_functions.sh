#!/bin/bash

# 科学上网功能：x-ui 一键部署
deploy_x_ui() {
    echo "正在部署 x-ui..."
    bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/x-ui/master/install.sh) || {
        echo "x-ui 部署失败，请检查网络或脚本链接。"
        pause
    }
    echo "x-ui 部署完成。"
    pause
}

# 科学上网功能：xboard 一键部署
deploy_xboard() {
    echo "正在部署 xboard... 请稍候..."

    # 切换到 /root 目录
    cd /root || { echo "无法切换到 /root 目录"; exit 1; }

    # 获取 Xboard Docker Compose 文件
    echo "正在获取 Xboard Docker Compose 文件..."
    git clone -b docker-compose --depth 1 https://github.com/cedar2025/Xboard xboard || {
        echo "获取 Xboard Docker Compose 文件失败"; exit 1;
    }
    cd /root/xboard || { echo "无法切换到 /root/xboard 目录"; exit 1; }
    echo "Xboard Docker Compose 文件获取完成"

    # 执行数据库安装命令
    echo "正在执行数据库安装命令..."
    docker compose run -it --rm xboard php artisan xboard:install || {
        echo "数据库安装命令执行失败"; exit 1;
    }
    echo "数据库安装完成，请记录后台地址和管理员账号密码"

    # 启动 Xboard
    echo "正在启动 Xboard..."
    docker compose up -d || { echo "Xboard 启动失败"; exit 1; }
    echo "Xboard 启动完成"

    # 提示访问网址
    echo "请访问 http://你的IP:7001/ 来体验 Xboard"
    echo "部署完成！"

    pause
}

# 科学上网功能：xrayr 一键部署
deploy_xrayr() {
    echo "正在部署 xrayr..."
    bash <(curl -Ls https://raw.githubusercontent.com/XrayR-project/XrayR-release/master/install.sh) || {
        echo "xrayr 部署失败，请检查网络或脚本链接。"
        pause
    }
    echo "xrayr 部署完成。"
    pause
}

# 科学上网管理菜单
vpn_menu() {
    while true; do
        clear
        echo "==============================="
        echo "      科学上网管理菜单        "
        echo "==============================="
        echo "1. 部署 x-ui"
        echo "2. 部署 xboard"
        echo "3. 部署 xrayr"
        echo "4. 返回主菜单"
        echo "==============================="
        read -p "请选择一个选项 (1-4): " choice

        case $choice in
            1) deploy_x_ui ;;         # 部署 x-ui
            2) deploy_xboard ;;       # 部署 xboard
            3) deploy_xrayr ;;        # 部署 xrayr
            4) break ;;               # 返回主菜单
            *) echo "无效选项，请重试"; sleep 2 ;;
        esac
    done
}

# 暂停等待用户操作
pause() {
    read -p "按 Enter 键继续..."
}
