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

shell 集成函数（`y` 命令用于 cd 到 yazi 退出时所在目录）已包含在
`references/bash_aliases.sh` 模板中。

## 依赖

通过 cargo 安装时需要 Rust 工具链。
