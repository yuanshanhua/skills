# eza

现代化的 `ls` 替代品，支持颜色、图标、Git 状态。

## 安装方式

| brew | nix | apt/dnf | cargo | 其他 |
|------|-----|---------|-------|------|
| ✅ | ✅ | — | ✅ | — |

### 推荐：cargo

```bash
cargo install eza
```

### brew

```bash
brew install eza
```

### nix

```bash
nix-env -iA nixpkgs.eza
```

## 安装后配置

可选添加别名到 `~/.bashrc_local`：

```bash
if command -v eza &>/dev/null; then
    alias ls='eza --color=auto --icons'
    alias ll='eza -alFh --icons'
    alias la='eza -ah --icons'
    alias lt='eza -l --sort=modified --icons'
fi
```

## 依赖

通过 cargo 安装时需要 Rust 工具链。
