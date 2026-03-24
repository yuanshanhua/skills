# Homebrew (Linuxbrew)

macOS 和 Linux 通用包管理器，可作为首选包管理器统一安装所有 CLI 工具。

## 分类

包管理器。当 `PREFERRED_PKG_MANAGER=brew` 时，此工具作为最高优先级首先安装，
随后通过 `brew install` 安装所有其他选定工具。

## 前置依赖

**Debian:**
```bash
apt-get install -y build-essential procps curl file git
```

**RHEL:**
```bash
dnf groupinstall -y "Development Tools"
dnf install -y procps-ng curl file git
```

## 安装

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

如果 `curl` 不可用，使用 `wget`：

```bash
/bin/bash -c "$(wget -qO- https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## 安装后配置

添加到 `~/.bashrc_local`：

```bash
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"
```

## 镜像配置

如果 `USE_MIRROR=true`，同时添加到 `~/.bashrc_local`：

```bash
export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"
export HOMEBREW_API_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"
export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
```

## 依赖

需要基础编译工具（build-essential / Development Tools）。
