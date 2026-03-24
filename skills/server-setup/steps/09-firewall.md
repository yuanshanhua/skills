# Phase 9: 防火墙配置

配置基础防火墙。Debian 系列使用 ufw，RHEL 系列使用 firewalld。

## 必要输入

来自 Q&A：

- `FIREWALL_PORTS` — 需开放的端口，逗号分隔（如 22,80,443）

如果用户在 Phase 4 中修改了 SSH 端口，**确保该端口包含在**开放端口列表中。
如果不在列表中，给出警告 — 他们可能会被锁在外面。

## Debian 系列 (ufw)

```bash
sudo apt-get install -y ufw

# 默认策略
sudo ufw default deny incoming
sudo ufw default allow outgoing

# 开放请求的端口
IFS=',' read -ra PORTS <<< "$FIREWALL_PORTS"
for port in "${PORTS[@]}"; do
    port=$(echo "$port" | xargs)  # 去除空格
    sudo ufw allow "$port/tcp"
    echo "已开放端口 $port/tcp"
done

# 启用（非交互）
sudo ufw --force enable
sudo ufw status verbose
```

## RHEL 系列 (firewalld)

```bash
sudo $PKG_MGR install -y firewalld
sudo systemctl start firewalld
sudo systemctl enable firewalld

# 开放请求的端口
IFS=',' read -ra PORTS <<< "$FIREWALL_PORTS"
for port in "${PORTS[@]}"; do
    port=$(echo "$port" | xargs)
    sudo firewall-cmd --permanent --add-port="${port}/tcp"
    echo "已开放端口 $port/tcp"
done

sudo firewall-cmd --reload
sudo firewall-cmd --list-all
```

## 安全检查

启用防火墙之前：

1. **SSH 端口必须开放。** 如果端口 22（或自定义 SSH 端口）不在列表中，
   自动添加并警告用户。
2. **测试连通性。** 启用后，告知用户在关闭当前会话之前从另一个终端验证 SSH 连接。
