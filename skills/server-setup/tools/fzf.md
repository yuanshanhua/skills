# fzf

模糊查找器，支持文件、历史记录、进程等的交互式模糊搜索。

## 安装方式

| brew | nix | apt/dnf | cargo | 其他 |
|------|-----|---------|-------|------|
| ✅ | ✅ | ✅（旧版） | — | git clone（推荐） |

### 推荐（git clone — 最新版本）

```bash
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all --no-zsh --no-fish
```

自动添加快捷键绑定和补全到 bashrc。

### brew

```bash
brew install fzf
```

### nix

```bash
nix-env -iA nixpkgs.fzf
```

## 安装后配置

git clone 方式会自动配置 shell 集成。
如果通过 brew/nix 安装，需要手动将快捷键绑定添加到 `~/.bashrc_local`。

## 依赖

无额外依赖。
