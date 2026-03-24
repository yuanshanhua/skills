# tmux

终端复用器，支持多窗口、窗格分割、会话持久化。

## 安装方式

| brew | nix | apt/dnf | cargo | 其他 |
|------|-----|---------|-------|------|
| ✅ | ✅ | ✅ | — | — |

### 推荐：系统包管理器

**Debian:**
```bash
apt-get install -y tmux
```

**RHEL:**
```bash
dnf install -y tmux
```

### brew

```bash
brew install tmux
```

### nix

```bash
nix-env -iA nixpkgs.tmux
```

## 安装后配置

可选：部署基础 `~/.tmux.conf`：

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

## 依赖

无额外依赖。
