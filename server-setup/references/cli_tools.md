# CLI 工具安装参考

各工具按安装方式的详细指令。
此 skill 在执行 Phase 7 时应查阅此文件。

当设置了 `PREFERRED_PKG_MANAGER` 时，所有工具使用对应列的方式安装。
当为 `none` 时，使用各工具列出的 "推荐" 方式。

---

## 包管理器

### Homebrew (Linuxbrew)

**前置依赖（Debian）:**
```bash
apt-get install -y build-essential procps curl file git
```

**前置依赖（RHEL）:**
```bash
dnf groupinstall -y "Development Tools"
dnf install -y procps-ng curl file git
```

**安装：**
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

如果 `curl` 不可用，使用 `wget`：
```bash
/bin/bash -c "$(wget -qO- https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**安装后 — 添加到 `~/.bashrc_local`：**
```bash
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"
```

**镜像**（如果 `USE_MIRROR=true`）：同时添加到 `~/.bashrc_local`：
```bash
export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"
export HOMEBREW_API_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"
export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
```

### Nix

**安装（单用户，无 daemon）：**
```bash
sh <(curl -L https://nixos.org/nix/install) --no-daemon
```

如果 `curl` 不可用：
```bash
sh <(wget -qO- https://nixos.org/nix/install) --no-daemon
```

**安装后 — source nix profile：**
```bash
. ~/.nix-profile/etc/profile.d/nix.sh
```

添加到 `~/.bashrc_local`：
```bash
if [ -e ~/.nix-profile/etc/profile.d/nix.sh ]; then
    . ~/.nix-profile/etc/profile.d/nix.sh
fi
```

**镜像**（如果 `USE_MIRROR=true`）：
```bash
mkdir -p ~/.config/nix
cat > ~/.config/nix/nix.conf << 'EOF'
substituters = https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store https://cache.nixos.org/
trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=
EOF
```

---

## CLI 工具

### fzf

**推荐（git clone — 最新版本）：**
```bash
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all --no-zsh --no-fish
```
自动添加快捷键绑定和补全到 bashrc。

**brew:** `brew install fzf`
**nix:** `nix-env -iA nixpkgs.fzf`

### ripgrep (rg)

**推荐：** 系统包管理器（打包良好，版本够新）。

**Debian:** `apt-get install -y ripgrep`
**RHEL (EPEL):** `dnf install -y ripgrep`
**brew:** `brew install ripgrep`
**nix:** `nix-env -iA nixpkgs.ripgrep`
**cargo:** `cargo install ripgrep`

### fd (fd-find)

**推荐：** 系统包管理器。

**Debian:**
```bash
apt-get install -y fd-find
# 注意：Debian 上二进制名为 fdfind，创建符号链接：
ln -sf $(which fdfind) ~/.local/bin/fd
```

**RHEL (EPEL):** `dnf install -y fd-find`
**brew:** `brew install fd`
**nix:** `nix-env -iA nixpkgs.fd`
**cargo:** `cargo install fd-find`

### bat

**推荐：** 系统包管理器。

**Debian:**
```bash
apt-get install -y bat
# 注意：Debian 上二进制名为 batcat，创建符号链接：
ln -sf $(which batcat) ~/.local/bin/bat
```

**RHEL (EPEL):** `dnf install -y bat`
**brew:** `brew install bat`
**nix:** `nix-env -iA nixpkgs.bat`
**cargo:** `cargo install bat`

### eza（现代 ls）

**推荐：** `cargo install eza`
**brew:** `brew install eza`
**nix:** `nix-env -iA nixpkgs.eza`

安装后：可选添加别名到 `~/.bashrc_local`：
```bash
if command -v eza &>/dev/null; then
    alias ls='eza --color=auto --icons'
    alias ll='eza -alFh --icons'
    alias la='eza -ah --icons'
    alias lt='eza -l --sort=modified --icons'
fi
```

### zoxide（智能 cd）

**推荐（安装脚本）：**
```bash
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
```

如果 `curl` 不可用：
```bash
wget -qO- https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
```

**brew:** `brew install zoxide`
**nix:** `nix-env -iA nixpkgs.zoxide`
**cargo:** `cargo install zoxide --locked`

安装后 — 添加到 `~/.bashrc_local`：
```bash
eval "$(zoxide init bash)"
```

### yazi（终端文件管理器）

**推荐（需要 Rust）：** `cargo install --locked yazi-fm yazi-cli`
**brew:** `brew install yazi`
**nix:** `nix-env -iA nixpkgs.yazi`

shell 集成函数（y）已包含在 bash_aliases 模板中。

### pueue（任务队列）

**推荐（需要 Rust）：** `cargo install --locked pueue`
**brew:** `brew install pueue`
**nix:** `nix-env -iA nixpkgs.pueue`

安装后：
```bash
# 启动守护进程
pueued -d
```

pueue 别名（t, tt 等）已包含在 bash_aliases 模板中，
在 pueue 安装后条件生效。

### tmux

**Debian:** `apt-get install -y tmux`
**RHEL:** `dnf install -y tmux`
**brew:** `brew install tmux`
**nix:** `nix-env -iA nixpkgs.tmux`

可选：部署基础 tmux.conf 到 `~/.tmux.conf`：
```bash
cat > ~/.tmux.conf << 'TMUXEOF'
# 重映射前缀键为 Ctrl+a
unbind C-b
set -g prefix C-a
bind C-a send-prefix

# 鼠标支持
set -g mouse on

# 窗口/窗格从 1 开始编号
set -g base-index 1
setw -g pane-base-index 1

# 256 色支持
set -g default-terminal "screen-256color"
set -sa terminal-overrides ',xterm-256color:RGB'

# 增加历史记录
set -g history-limit 50000

# 用 | 和 - 分割窗格
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"

# 重新加载配置
bind r source-file ~/.tmux.conf \; display "配置已重载!"
TMUXEOF
```

### btop（系统监控）

**Debian (22.04+):** `apt-get install -y btop`
**RHEL (EPEL):** `dnf install -y btop`
**brew:** `brew install btop`
**nix:** `nix-env -iA nixpkgs.btop`
