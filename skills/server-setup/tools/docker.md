# Docker

容器运行时引擎，包含 Docker Engine、CLI 和 Docker Compose 插件。

## 分类

容器运行时。由于涉及系统服务和内核特性，**建议通过官方仓库或系统包管理器安装**，
即使用户首选 brew/nix 也建议走系统方式。安装前向用户说明原因。

## 安装方式

| brew | nix | apt/dnf | cargo | 其他 |
|------|-----|---------|-------|------|
| ⚠️ | ⚠️ | ✅ | — | 官方脚本（推荐） |

> ⚠️ = 可安装但建议通过系统包管理器/官方仓库安装

### Debian 系列

```bash
# 方式一：官方便捷脚本（推荐）
curl -fsSL https://get.docker.com | sh
```

如果便捷脚本因网络问题失败且 `USE_MIRROR=true`：

```bash
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

### RHEL 系列

```bash
# 添加 Docker 官方仓库
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo systemctl start docker
sudo systemctl enable docker
```

如果 `USE_MIRROR=true`，使用镜像仓库：

```bash
sudo dnf config-manager --add-repo https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/docker-ce.repo
sudo sed -i 's+https://download.docker.com+https://mirrors.tuna.tsinghua.edu.cn/docker-ce+' /etc/yum.repos.d/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

## Docker Compose

`docker-compose-plugin` 已随上述步骤一起安装，提供 `docker compose`（V2 子命令）。
如果用户还需要独立的 `docker-compose`（V1 风格命令）：

```bash
# 一般不需要，V2 已内置。仅在特殊兼容需求时安装：
sudo ln -sf /usr/libexec/docker/cli-plugins/docker-compose /usr/local/bin/docker-compose
```

## Registry 镜像（换源）

如果 `USE_MIRROR=true`：

```bash
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json << 'EOF'
{
    "registry-mirrors": [
        "https://docker.mirrors.ustc.edu.cn",
        "https://hub-mirror.c.163.com"
    ]
}
EOF
sudo systemctl restart docker
```

覆盖前检查 `daemon.json` 是否已存在 — 如需要则合并内容。

## 将用户加入 docker 组

如果用户选择了此项：

```bash
sudo usermod -aG docker $USER
```

**提醒用户：** 需要注销并重新登录（或运行 `newgrp docker`）组变更才会生效。
在此之前，docker 命令需要 `sudo`。

## 验证

```bash
docker --version
docker compose version
sudo docker run hello-world
```

## 与 Podman 的兼容性

如果用户同时安装了 Docker 和 Podman，提醒可能的冲突：

- 两者的 CLI 高度兼容，可通过 `alias docker=podman` 切换
- 但 daemon 模式不同：Docker 需要 `dockerd`，Podman 是 daemonless
- Compose 文件格式兼容，但 `podman-compose` 和 `docker compose` 的行为可能有细微差异
- 建议用户选择其一作为主力，避免混淆

## 依赖

需要 root/sudo 权限安装和配置。
