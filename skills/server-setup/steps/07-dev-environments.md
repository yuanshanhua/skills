# Phase 7: 开发环境

仅安装用户选定的环境。每个章节相互独立。
如果 `USE_MIRROR=true`，为每个工具应用相应的镜像配置。

---

## Python — Miniconda

```bash
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh
bash /tmp/miniconda.sh -b -p "$HOME/miniconda3"
"$HOME/miniconda3/bin/conda" init bash
"$HOME/miniconda3/bin/conda" config --set auto_activate_base false
rm /tmp/miniconda.sh
```

**镜像配置**（如果 `USE_MIRROR=true`）：

安装完成后配置 conda channels 镜像：

```bash
cat > ~/.condarc << 'EOF'
channels:
  - defaults
show_channel_urls: true
default_channels:
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/r
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/msys2
custom_channels:
  conda-forge: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  pytorch: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
EOF
```

同时配置 pip 镜像（conda 环境中的 pip 也需要）：

```bash
mkdir -p ~/.pip
cat > ~/.pip/pip.conf << 'EOF'
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
trusted-host = pypi.tuna.tsinghua.edu.cn
EOF
```

---

## Python — uv

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

**镜像配置**（如果 `USE_MIRROR=true`）：

uv 读取 `UV_INDEX_URL` 环境变量，也兼容 pip.conf。安装后配置：

```bash
# pip.conf（uv 也会读取）
mkdir -p ~/.pip
cat > ~/.pip/pip.conf << 'EOF'
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
trusted-host = pypi.tuna.tsinghua.edu.cn
EOF

# 显式设置 UV_INDEX_URL
echo 'export UV_INDEX_URL="https://pypi.tuna.tsinghua.edu.cn/simple"' >> ~/.bashrc_local
```

> 如果同时安装了 conda，pip.conf 只需写入一次。

---

## Node.js — nvm

**镜像**（如果 `USE_MIRROR=true`，安装前设置）：

```bash
export NVM_NODEJS_ORG_MIRROR=https://npmmirror.com/mirrors/node
```

安装 nvm：

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
```

如果上述失败（GitHub 被阻断），使用镜像：

```bash
# 备选：使用 gitee 镜像
curl -o- https://gitee.com/mirrors/nvm/raw/v0.40.1/install.sh | bash
```

然后安装 Node LTS：

```bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install --lts
```

**npm 镜像**（如果 `USE_MIRROR=true`，安装 Node 后配置）：

```bash
npm config set registry https://registry.npmmirror.com
```

持久化 NVM_NODEJS_ORG_MIRROR（便于后续安装其他 Node 版本）：

```bash
echo 'export NVM_NODEJS_ORG_MIRROR=https://npmmirror.com/mirrors/node' >> ~/.bashrc_local
```

---

## Go

```bash
GO_VERSION=$(curl -s https://go.dev/VERSION?m=text | head -1)
wget "https://go.dev/dl/${GO_VERSION}.linux-amd64.tar.gz" -O /tmp/go.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf /tmp/go.tar.gz
rm /tmp/go.tar.gz
```

添加到 `~/.bashrc_local`：

```bash
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bashrc_local
```

**镜像配置**（如果 `USE_MIRROR=true`，安装后配置）：

```bash
echo 'export GOPROXY=https://goproxy.cn,direct' >> ~/.bashrc_local
```

对于 aarch64 系统，下载 URL 中将 `amd64` 替换为 `arm64`。

---

## Rust (rustup)

**镜像**（如果 `USE_MIRROR=true`，安装前设置环境变量）：

```bash
export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup
```

安装：

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"
```

**cargo 镜像**（如果 `USE_MIRROR=true`，安装后配置）：

```bash
mkdir -p ~/.cargo
cat >> ~/.cargo/config.toml << 'EOF'
[source.crates-io]
replace-with = 'ustc'

[source.ustc]
registry = "sparse+https://mirrors.ustc.edu.cn/crates.io-index/"
EOF
```

持久化 rustup 镜像变量（便于后续 `rustup update`）：

```bash
echo 'export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static' >> ~/.bashrc_local
echo 'export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup' >> ~/.bashrc_local
```

---

## Java (OpenJDK)

用户应指定版本：11、17 或 21。

**Debian:**

```bash
sudo apt-get install -y openjdk-${JAVA_VERSION}-jdk
```

**RHEL:**

```bash
sudo $PKG_MGR install -y java-${JAVA_VERSION}-openjdk-devel
```

在 `~/.bashrc_local` 中设置 JAVA_HOME：

```bash
JAVA_PATH=$(dirname $(dirname $(readlink -f $(which java))))
echo "export JAVA_HOME=$JAVA_PATH" >> ~/.bashrc_local
```

---

## 验证

安装每个环境后验证：

```bash
conda --version 2>/dev/null
uv --version 2>/dev/null
node --version 2>/dev/null && npm --version 2>/dev/null
go version 2>/dev/null
rustc --version 2>/dev/null && cargo --version 2>/dev/null
java -version 2>/dev/null
```
