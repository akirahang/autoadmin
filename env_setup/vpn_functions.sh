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
    echo "正在部署 xboard..."
    bash <(curl -Ls https://raw.githubusercontent.com/CokeMine/Xray-dashboard-install/main/install.sh) || {
        echo "xboard 部署失败，请检查网络或脚本链接。"
        pause
    }
    echo "xboard 部署完成。"
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
