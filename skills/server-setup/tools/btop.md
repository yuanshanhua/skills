# btop

现代化系统资源监控器，支持 CPU、内存、磁盘、网络、进程可视化。

## 安装方式

| brew | nix | apt/dnf | cargo | 其他 |
|------|-----|---------|-------|------|
| ✅ | ✅ | ✅（22.04+） | — | — |

### 推荐：系统包管理器

**Debian (22.04+):**
```bash
apt-get install -y btop
```

**RHEL (EPEL):**
```bash
dnf install -y btop
```

### brew

```bash
brew install btop
```

### nix

```bash
nix-env -iA nixpkgs.btop
```

## 依赖

无额外依赖。
