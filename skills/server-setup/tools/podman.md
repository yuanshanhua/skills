# Podman

无 daemon 容器运行时，与 Docker CLI 高度兼容，原生支持 rootless 模式。

## 分类

容器运行时。由于涉及系统服务和内核特性，**建议通过系统包管理器安装**，
即使用户首选 brew/nix 也建议走系统方式。安装前向用户说明原因。

## 安装方式

| brew | nix | apt/dnf | cargo | 其他 |
|------|-----|---------|-------|------|
| ⚠️ | ✅ | ✅ | — | — |

> ⚠️ = 可安装但建议通过系统包管理器/官方仓库安装

### Debian 系列

```bash
sudo apt-get install -y podman
```

如果系统仓库版本过旧（< 4.x），使用 Kubic 仓库获取新版：

```bash
# Ubuntu
. /etc/os-release
echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/unstable/xUbuntu_${VERSION_ID}/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:unstable.list
curl -fsSL "https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/unstable/xUbuntu_${VERSION_ID}/Release.key" | sudo gpg --dearmor -o /etc/apt/keyrings/devel_kubic_libcontainers_unstable.gpg
sudo apt-get update
sudo apt-get install -y podman
```

### RHEL 系列

```bash
sudo dnf install -y podman
```

RHEL 系列通常自带或仓库中有较新版本的 Podman，无需额外配置仓库。

## Podman Compose

Podman Compose 是一个独立的 Python 工具，兼容 `docker-compose.yml` 格式：

```bash
# 通过 pip 安装（推荐）
pip install podman-compose

# 或通过系统包管理器（如果可用）
# Debian: sudo apt-get install -y podman-compose
# RHEL:   sudo dnf install -y podman-compose
```

## Registry 镜像（换源）

如果 `USE_MIRROR=true`，配置 Podman 使用国内镜像：

### 用户级配置

```bash
mkdir -p ~/.config/containers
cat > ~/.config/containers/registries.conf << 'EOF'
unqualified-search-registries = ["docker.io"]

[[registry]]
prefix = "docker.io"
location = "docker.io"

[[registry.mirror]]
location = "docker.mirrors.ustc.edu.cn"

[[registry.mirror]]
location = "hub-mirror.c.163.com"
EOF
```

### 全局配置（需要 sudo）

```bash
sudo tee /etc/containers/registries.conf << 'EOF'
unqualified-search-registries = ["docker.io"]

[[registry]]
prefix = "docker.io"
location = "docker.io"

[[registry.mirror]]
location = "docker.mirrors.ustc.edu.cn"

[[registry.mirror]]
location = "hub-mirror.c.163.com"
EOF
```

## 用户组与 Rootless 模式

Podman 默认支持 rootless 模式，无需 root 权限即可运行容器。
确保用户有 subuid/subgid 映射：

```bash
# 检查是否已配置
grep "^$(whoami):" /etc/subuid

# 如果没有，添加映射
sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 $USER
podman system migrate
```

如果用户需要类似 Docker 的 socket 兼容（供第三方工具使用）：

```bash
systemctl --user enable --now podman.socket
export DOCKER_HOST=unix:///run/user/$(id -u)/podman/podman.sock
```

将环境变量添加到 `~/.bashrc_local`。

## 验证

```bash
podman --version
podman-compose --version
podman run hello-world
```

## 与 Docker 的兼容性

如果用户同时安装了 Docker 和 Podman，提醒可能的冲突：

- 两者的 CLI 高度兼容，可通过 `alias docker=podman` 切换
- 但 daemon 模式不同：Docker 需要 `dockerd`，Podman 是 daemonless
- Compose 文件格式兼容，但 `podman-compose` 和 `docker compose` 的行为可能有细微差异
- 建议用户选择其一作为主力，避免混淆

## 依赖

- Rootless 模式需要内核支持 user namespaces
- `podman-compose` 需要 Python 和 pip
