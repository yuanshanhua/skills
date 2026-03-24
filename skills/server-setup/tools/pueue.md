# pueue

后台任务队列管理器，支持并行执行、依赖和日志。
此工具有守护进程和客户端两个组件, 命令名分别为 pueued 和 pueue,
在安装检查时需要同时检查二者

## 安装方式

| brew | nix | apt/dnf | cargo | 其他 |
|------|-----|---------|-------|------|
| ✅ | ✅ | — | ✅ | — |

### 推荐：cargo（需要 Rust）

```bash
cargo install --locked pueue
```

### brew

```bash
brew install pueue
```

### nix

```bash
nix-env -iA nixpkgs.pueue
```

## 安装后配置

添加常用操作别名:

```bash
# ─── pueue ──────────────────────────────────────────────────────────────────
alias t='pueue'
alias tt='pueue add -s'
alias t-re='pueue restart -is'
alias t-kill='pueue kill -s 9'
```

## 依赖

通过 cargo 安装时需要 Rust 工具链。
