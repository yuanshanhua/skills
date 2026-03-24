# yazi

终端文件管理器，支持图片预览、异步 I/O。

## 安装方式

| brew | nix | apt/dnf | cargo | 其他 |
|------|-----|---------|-------|------|
| ✅ | ✅ | — | ✅ | — |

### 推荐：cargo（需要 Rust）

```bash
cargo install --locked yazi-fm yazi-cli
```

### brew

```bash
brew install yazi
```

### nix

```bash
nix-env -iA nixpkgs.yazi
```

## 安装后配置

在 `~/.bash_aliases` 中添加函数 `y` 用于自动 cd 到 yazi 退出时所在目录:

```bash
# yazi
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    command yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
}
```

## 依赖

通过 cargo 安装时需要 Rust 工具链。
