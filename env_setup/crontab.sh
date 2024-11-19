#!/bin/bash

# Cron 模块功能函数

# 查看当前 Cron 任务
list_cron_jobs() {
    clear
    echo "当前的 Cron 任务列表："
    crontab -l || echo "当前没有任何 Cron 任务。"
    pause
}

# 添加新任务
add_cron_job() {
    read -p "请输入新的 Cron 任务时间表达式 (例如: '0 5 * * *'): " time_expr
    read -p "请输入要执行的命令: " command

    if [[ -z "$time_expr" || -z "$command" ]]; then
        echo "时间表达式或命令不能为空！"
        pause
        return
    fi

    (crontab -l 2>/dev/null; echo "$time_expr $command") | crontab -
    echo "新任务已添加：$time_expr $command"
    pause
}

# 删除任务
delete_cron_job() {
    clear
    echo "当前的 Cron 任务列表："
    crontab -l || { echo "当前没有任何 Cron 任务。"; pause; return; }

    read -p "请输入要删除的任务的完整行内容: " job_to_remove
    if [[ -z "$job_to_remove" ]]; then
        echo "输入不能为空！"
        pause
        return
    fi

    # 删除任务
    crontab -l | grep -v "$job_to_remove" | crontab -
    echo "任务已删除：$job_to_remove"
    pause
}

# Cron 任务管理菜单
cron_task_menu() {
    while true; do
        clear
        echo "==============================="
        echo "      Cron 任务管理菜单       "
        echo "==============================="
        echo "1. 查看当前 Cron 任务"
        echo "2. 添加新 Cron 任务"
        echo "3. 删除 Cron 任务"
        echo "4. 返回主菜单"
        echo "==============================="
        read -p "请选择一个选项 (1-4): " choice

        case $choice in
            1) list_cron_jobs ;;     # 查看当前 Cron 任务
            2) add_cron_job ;;       # 添加新任务
            3) delete_cron_job ;;    # 删除任务
            4) break ;;              # 返回主菜单
            *) echo "无效选项，请重试"; sleep 2 ;;
        esac
    done
}

# 暂停等待用户操作
pause() {
    read -p "按 Enter 键继续..."
}
