# Phase 1: 网络探测与镜像源

此步骤判断服务器对国际源（GitHub、PyPI、Docker Hub 等）的直连质量，
决定是否需要配置国内镜像源。这个决定会**影响后续所有下载操作**。

## 为什么重要

国内服务器访问以下资源会很慢或不稳定：

- GitHub raw/releases（nvm、fzf、rustup、Homebrew）
- PyPI（pip install）
- Anaconda channels（conda）
- npm registry
- Docker Hub
- Go module proxy（proxy.golang.org）
- crates.io（cargo）

提前配置镜像可以让一切又快又稳。但如果服务器网络环境良好则不必配置。

## Step 1: 探测网络环境

运行 `scripts/network-probe.sh` 脚本探测国际网络连通性。脚本会自动检测可用的
HTTP 工具（curl → wget → ping），10 秒内完成所有探测，输出自然语言可读报告。

```bash
bash scripts/network-probe.sh
```

> 探测逻辑已封装在脚本中，无需在上下文里展开。脚本输出示例：
>
> ```bash
> ===== 网络连通性探测报告 =====
>
> 探测工具: curl
>
> --- 探测结果 ---
> PyPI (pypi.org):             可达，响应时间 0.312s
> GitHub (github.com):        可达，响应时间 0.523s
> TUNA 镜像 (tsinghua.edu.cn): 可达，响应时间 0.041s
> =============================
> ```

根据探测结果来判断是否需要使用镜像源。

## Step 2: 向用户展示结果

向用户展示脚本结果和推荐使用镜像源与否, 并询问用户 `是否使用国内镜像源? [y/n]`

根据用户回答设置 `USE_MIRROR`。

## Step 3: 系统包管理器镜像配置

仅在 `USE_MIRROR=true` 时执行此节。

### apt 镜像（Debian 系列）

备份并替换 `/etc/apt/sources.list`（或 `/etc/apt/sources.list.d/` 中的文件）：

**Ubuntu:**

```bash
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak.$(date +%Y%m%d)

# Ubuntu 22.04+ 使用 deb822 格式：
if [ -f /etc/apt/sources.list.d/ubuntu.sources ]; then
    sudo cp /etc/apt/sources.list.d/ubuntu.sources /etc/apt/sources.list.d/ubuntu.sources.bak
    sudo sed -i 's|http://archive.ubuntu.com|https://mirrors.tuna.tsinghua.edu.cn|g' /etc/apt/sources.list.d/ubuntu.sources
    sudo sed -i 's|http://security.ubuntu.com|https://mirrors.tuna.tsinghua.edu.cn|g' /etc/apt/sources.list.d/ubuntu.sources
else
    sudo sed -i 's|http://archive.ubuntu.com|https://mirrors.tuna.tsinghua.edu.cn|g' /etc/apt/sources.list
    sudo sed -i 's|http://security.ubuntu.com|https://mirrors.tuna.tsinghua.edu.cn|g' /etc/apt/sources.list
fi
```

**Debian:**

```bash
sudo sed -i 's|http://deb.debian.org|https://mirrors.tuna.tsinghua.edu.cn|g' /etc/apt/sources.list
sudo sed -i 's|http://security.debian.org|https://mirrors.tuna.tsinghua.edu.cn|g' /etc/apt/sources.list
```

### dnf/yum 镜像（RHEL 系列）

**CentOS / TencentOS:**

```bash
# 备份现有 repo 文件
sudo cp -r /etc/yum.repos.d /etc/yum.repos.d.bak.$(date +%Y%m%d)

# CentOS 8+ / TencentOS，替换 .repo 文件中的镜像
sudo sed -i 's|^mirrorlist=|#mirrorlist=|g' /etc/yum.repos.d/CentOS-*.repo 2>/dev/null
sudo sed -i 's|^#baseurl=http://mirror.centos.org|baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos|g' /etc/yum.repos.d/CentOS-*.repo 2>/dev/null
```

注意：TencentOS 可能有自己的 repo 结构。检查实际的 repo 文件并适配。
如果已使用腾讯自己的镜像（mirrors.tencent.com），从腾讯云内部访问本身就很快 —
无需修改。不确定时询问用户。

## 注意事项

- 修改系统 repo 文件前始终备份
- 腾讯云内的 TencentOS 很可能已有快速镜像 — 需检测
- 如果服务器在阿里云、腾讯云或华为云上，它们的内部镜像最快。考虑使用云厂商专用镜像
- **此文件只配置系统包管理器（apt/dnf）的镜像**。其他工具（pip、conda、npm、cargo、Go、Docker、Homebrew 等）的镜像配置在各自的安装步骤中进行（`07-dev-environments.md`、`08-cli-tools.md`、`09-docker.md`），确保镜像在工具安装时或安装后立即设置
