# fd (fd-find)

简单、快速、用户友好的 `find` 替代品。

## 安装方式

| brew | nix | apt/dnf | cargo | 其他 |
|------|-----|---------|-------|------|
| ✅ | ✅ | ✅ | ✅ | — |

### 推荐：系统包管理器

**Debian:**
```bash
apt-get install -y fd-find
# 注意：Debian 上二进制名为 fdfind，创建符号链接：
ln -sf $(which fdfind) ~/.local/bin/fd
```

**RHEL (EPEL):**
```bash
dnf install -y fd-find
```

### brew

```bash
brew install fd
```

### nix

```bash
nix-env -iA nixpkgs.fd
```

### cargo

```bash
cargo install fd-find
```

## 注意事项

- Debian/Ubuntu 上包名为 `fd-find`，二进制名为 `fdfind`，需手动创建 `fd` 符号链接。
- 确保 `~/.local/bin` 在 `$PATH` 中。

## 依赖

通过 cargo 安装时需要 Rust 工具链。
