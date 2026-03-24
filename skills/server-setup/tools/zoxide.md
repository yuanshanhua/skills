# zoxide

智能 `cd` 命令，基于使用频率和最近访问自动跳转目录。

## 安装方式

| brew | nix | apt/dnf | cargo | 其他 |
|------|-----|---------|-------|------|
| ✅ | ✅ | — | ✅ | 安装脚本（推荐） |

### 推荐：官方安装脚本

```bash
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
```

如果 `curl` 不可用：

```bash
wget -qO- https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
```

### brew

```bash
brew install zoxide
```

### nix

```bash
nix-env -iA nixpkgs.zoxide
```

### cargo

```bash
cargo install zoxide --locked
```

## 安装后配置

添加到 `~/.bashrc_local`：

```bash
eval "$(zoxide init bash)"
```

## 依赖

通过 cargo 安装时需要 Rust 工具链。
