# Phase 0: 检测发行版与环境

这是第一个步骤。检测 Linux 发行版系列并设置所有后续步骤依赖的全局变量。

## 检测逻辑

```bash
# 读取系统信息
if [ -f /etc/os-release ]; then
    . /etc/os-release
fi
```

根据 `ID` 和 `ID_LIKE` 字段分类：

| DISTRO_FAMILY | 匹配条件（ID 或 ID_LIKE 包含） |
|---------------|-------------------------------|
| `debian` | ubuntu, debian, linuxmint, pop |
| `rhel` | centos, rhel, rocky, almalinux, tencentos, fedora, ol (Oracle Linux) |

TencentOS 是 CentOS 变体 — 按 CentOS 同等对待。

## 设置包管理器

```bash
if [[ "$DISTRO_FAMILY" == "debian" ]]; then
    PKG_UPDATE="apt-get update"
    PKG_UPGRADE="apt-get upgrade -y"
    PKG_INSTALL="apt-get install -y"
elif [[ "$DISTRO_FAMILY" == "rhel" ]]; then
    # 优先 dnf；回退到 yum
    if command -v dnf &>/dev/null; then
        PKG_MGR="dnf"
    else
        PKG_MGR="yum"
    fi
    PKG_UPDATE="$PKG_MGR makecache"
    PKG_UPGRADE="$PKG_MGR update -y"
    PKG_INSTALL="$PKG_MGR install -y"
fi
```

## RHEL: 确保启用 EPEL

许多工具（ripgrep、bat、fd、btop）在 EPEL 仓库中。尽早启用：

```bash
if [[ "$DISTRO_FAMILY" == "rhel" ]]; then
    if ! rpm -q epel-release &>/dev/null; then
        $PKG_INSTALL epel-release
    fi
fi
```

## 检查 sudo 权限

```bash
if sudo -n true 2>/dev/null; then
    HAS_SUDO=true
else
    HAS_SUDO=false
    # 告知用户：部分步骤（系统包、防火墙、sshd 配置）需要 root 权限
fi
```

## 输出

此步骤完成后，应建立并向用户报告以下信息：

- 发行版名称 + 版本（如 "Ubuntu 22.04" 或 "TencentOS 4.4"）
- DISTRO_FAMILY（debian 或 rhel）
- 包管理器（apt / dnf / yum）
- sudo 是否可用
- CPU 架构（x86_64, aarch64）— 影响二进制文件下载
