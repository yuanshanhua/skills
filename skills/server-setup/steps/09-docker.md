# Phase 9: Docker

安装 Docker Engine 和 Docker Compose 插件。

## Debian 系列

```bash
# 通过便捷脚本安装
curl -fsSL https://get.docker.com | sh
```

## RHEL 系列

```bash
# 添加 Docker 仓库
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo systemctl start docker
sudo systemctl enable docker
```

## 镜像影响

如果 `USE_MIRROR=true`，配置 Docker registry 镜像：

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

覆盖前检查 daemon.json 是否已存在 — 如需要则合并内容。

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

## 通过镜像安装 Docker（国内网络）

如果便捷脚本因网络问题失败且 `USE_MIRROR=true`：

**Debian:**
```bash
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

**RHEL:**
```bash
sudo dnf config-manager --add-repo https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/docker-ce.repo
sudo sed -i 's+https://download.docker.com+https://mirrors.tuna.tsinghua.edu.cn/docker-ce+' /etc/yum.repos.d/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
```
