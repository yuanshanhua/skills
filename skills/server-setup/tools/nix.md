# Nix

函数式包管理器，支持可重复构建。可作为首选包管理器统一安装所有 CLI 工具。

## 分类

包管理器。当 `PREFERRED_PKG_MANAGER=nix` 时，此工具作为最高优先级首先安装，
随后通过 `nix-env -iA` 安装所有其他选定工具。

## 安装（单用户，无 daemon）

```bash
sh <(curl -L https://nixos.org/nix/install) --no-daemon
```

如果 `curl` 不可用：

```bash
sh <(wget -qO- https://nixos.org/nix/install) --no-daemon
```

## 安装后配置

source nix profile：

```bash
. ~/.nix-profile/etc/profile.d/nix.sh
```

添加到 `~/.bashrc_local`：

```bash
if [ -e ~/.nix-profile/etc/profile.d/nix.sh ]; then
    . ~/.nix-profile/etc/profile.d/nix.sh
fi
```

## 镜像配置

如果 `USE_MIRROR=true`：

```bash
mkdir -p ~/.config/nix
cat > ~/.config/nix/nix.conf << 'EOF'
substituters = https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store https://cache.nixos.org/
trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=
EOF
```

## 依赖

无额外依赖。
