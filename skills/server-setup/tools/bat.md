# bat

带语法高亮和 Git 集成的 `cat` 替代品。

## 安装方式

| brew | nix | apt/dnf | cargo | 其他 |
|------|-----|---------|-------|------|
| ✅ | ✅ | ✅ | ✅ | — |

### 推荐：系统包管理器

**Debian:**
```bash
apt-get install -y bat
# 注意：Debian 上二进制名为 batcat，创建符号链接：
ln -sf $(which batcat) ~/.local/bin/bat
```

**RHEL (EPEL):**
```bash
dnf install -y bat
```

### brew

```bash
brew install bat
```

### nix

```bash
nix-env -iA nixpkgs.bat
```

### cargo

```bash
cargo install bat
```

## 注意事项

- Debian/Ubuntu 上包名为 `bat`，但二进制名为 `batcat`，需手动创建 `bat` 符号链接。
- 确保 `~/.local/bin` 在 `$PATH` 中。

## 依赖

通过 cargo 安装时需要 Rust 工具链。
