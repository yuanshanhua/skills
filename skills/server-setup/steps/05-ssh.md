# Phase 5: SSH 密钥生成与安全加固

仅在用户在 Q&A 中选择时执行。

## Part A: 生成 SSH 密钥

```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
ssh-keygen -t ed25519 -C "$GIT_USER_EMAIL" -f ~/.ssh/id_ed25519 -N ""
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
```

生成后展示公钥：
```bash
echo ""
echo "=== 你的 SSH 公钥（添加到 GitHub/GitLab 等） ==="
cat ~/.ssh/id_ed25519.pub
echo "================================================="
```

## Part B: 加固 sshd_config（需要 root）

**关键警告：** 禁用密码认证之前，确认：
1. 用户有服务器的控制台/VNC 访问作为备用
2. 或者已有可认证的 SSH 密钥
3. 或者用户在机器前操作

如果以上都不满足，**不要禁用密码认证** — 用户可能会被锁在外面。

### 应用更改

```bash
SSHD_CONFIG="/etc/ssh/sshd_config"
sudo cp "$SSHD_CONFIG" "${SSHD_CONFIG}.bak.$(date +%Y%m%d)"
```

如果用户要求禁用密码登录：
```bash
sudo sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication no/' "$SSHD_CONFIG"
sudo sed -i 's/^#\?PubkeyAuthentication .*/PubkeyAuthentication yes/' "$SSHD_CONFIG"
```

禁用 root 登录（始终推荐）：
```bash
sudo sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin no/' "$SSHD_CONFIG"
```

如果用户要求修改 SSH 端口：
```bash
sudo sed -i "s/^#\?Port .*/Port $SSH_PORT/" "$SSHD_CONFIG"
```

### 重启 sshd

```bash
sudo systemctl restart sshd
```

如果用户修改了端口，提醒他们：
- 更新 SSH 客户端配置
- 更新防火墙规则以放行新端口
- 在关闭当前会话**之前**从另一个终端测试连接
