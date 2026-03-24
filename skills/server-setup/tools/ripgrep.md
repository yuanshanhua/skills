# ripgrep (rg)

递归正则搜索工具，比 grep 更快。

## 安装方式

| brew | nix | apt/dnf | cargo | 其他 |
|------|-----|---------|-------|------|
| ✅ | ✅ | ✅ | ✅ | — |

### 推荐：系统包管理器（打包良好，版本够新）

**Debian:**
```bash
apt-get install -y ripgrep
```

**RHEL (EPEL):**
```bash
dnf install -y ripgrep
```

### brew

```bash
brew install ripgrep
```

### nix

```bash
nix-env -iA nixpkgs.ripgrep
```

### cargo

```bash
cargo install ripgrep
```

## 依赖

通过 cargo 安装时需要 Rust 工具链。
