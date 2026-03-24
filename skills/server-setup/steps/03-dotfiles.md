# Phase 3: Shell 配置（Dotfiles）

根据 `CONFIG_SOURCE` 部署 shell 配置文件，该变量在 Q&A 中确定。

---

## 模式 A: 内置默认（`CONFIG_SOURCE=builtin`）

使用此 skill 附带的精选配置。

### 需部署的文件

| 文件 | 来源 | 说明 |
|------|------|------|
| `~/.bashrc` | `references/bashrc.sh` | 主 shell 配置：PS1、历史记录、环境变量 |
| `~/.bash_aliases` | `references/bash_aliases.sh` | 别名、函数、工具集成 |
| `~/.bashrc_local` | （不存在则创建空文件） | 机器特定的覆盖配置 |

### 步骤

1. 备份现有文件（见下方备份章节）
2. 复制 `references/bashrc.sh` →  `~/.bashrc`
3. 复制 `references/bash_aliases.sh` →  `~/.bash_aliases`
4. 如果 `~/.bashrc_local` 不存在则创建

### 默认配置的主要特性

**.bashrc:**
- 非交互模式守卫
- 历史记录：内存 10000 条，磁盘 20000 条，带时间戳，追加模式
- Shell 选项：globstar、cdspell、autocd、checkwinsize
- PS1：`user@host cwd (git-branch) (python-env)`，退出状态以颜色区分
- 条件工具加载（nvm、conda、brew、cargo — 仅在已安装时）
- Source `~/.bash_aliases` 和 `~/.bashrc_local`

**.bash_aliases:**
- 安全文件操作（cp -iv, mv -iv, rm -Iv）
- Git 别名（gs, ga, glog, gd, gcm 等）
- 条件 pueue/yazi 集成（仅在已安装时）
- 实用函数：mkcd, extract, ftext, bak

---

## 模式 B: Dotfiles 仓库（`CONFIG_SOURCE=repo:<url>`）

克隆用户的 dotfiles 仓库并部署其内容。

### 步骤

1. 克隆仓库：
   ```bash
   DOTFILES_DIR=$(mktemp -d)
   git clone --depth 1 "$REPO_URL" "$DOTFILES_DIR"
   ```

2. **检测仓库布局。** 扫描配置文件：

   ```
   # 检查扁平布局（文件在仓库根目录）
   if [ -f "$DOTFILES_DIR/.bashrc" ] || [ -f "$DOTFILES_DIR/bashrc" ]; then
       LAYOUT="flat"
   # 检查 stow 布局（按目录分组）
   elif [ -d "$DOTFILES_DIR/bash" ] || [ -d "$DOTFILES_DIR/shell" ]; then
       LAYOUT="stow"
   fi
   ```

   识别的文件模式（有无前导点号均可）：

   | 模式 | 部署到 |
   |------|--------|
   | `.bashrc` / `bashrc` | `~/.bashrc` |
   | `.bash_aliases` / `bash_aliases` | `~/.bash_aliases` |
   | `.bash_profile` / `bash_profile` | `~/.bash_profile` |
   | `.vimrc` / `vimrc` | `~/.vimrc` |
   | `.tmux.conf` / `tmux.conf` | `~/.tmux.conf` |
   | `.gitconfig` / `gitconfig` | `~/.gitconfig` |
   | `.config/<tool>/` | `~/.config/<tool>/` |

3. **检查安装脚本。** 如果仓库根目录有 `install.sh`、`setup.sh` 或 `bootstrap.sh`：
   - 向用户展示其内容（或过长时展示摘要）
   - 询问："你的 dotfiles 仓库有安装脚本，是否运行？[y/n]"
   - 同意则运行，否则手动部署文件。

4. **检查工具列表。** 扫描仓库中指定包的文件：
   - `packages.txt` / `tools.txt` — 纯文本，每行一个
   - `Brewfile` — 解析 brew install 行
   - `install-packages.sh` — 展示并询问后再运行

   如果找到，从此文件设置 `CUSTOM_TOOLS`。告知用户：
   "在你的 dotfiles 仓库中找到了工具列表（packages.txt），将在 CLI 工具阶段使用。
   需要先查看或修改吗？"

5. 备份现有文件，然后从克隆的仓库部署。

6. 如果仓库中没有 `~/.bashrc_local` 则创建。

7. 清理临时目录（或用户需要时保留）：
   ```bash
   rm -rf "$DOTFILES_DIR"
   ```

### 处理缺失文件

如果仓库不包含 `.bashrc` 或 `.bash_aliases`：
- 询问用户："你的 dotfiles 仓库不包含 .bashrc，是否使用内置默认配置，
  还是跳过 shell 配置？"
- 用户同意时，对缺失的文件回退到模式 A。

---

## 模式 C: 扫描当前机器（`CONFIG_SOURCE=scan`）

读取当前机器的 shell 配置并复制到目标。

### 步骤

1. 读取当前机器的 `~/.bashrc`。
2. 读取 `~/.bash_aliases`（如果存在）。
3. 读取其他常见配置文件：`~/.vimrc`、`~/.tmux.conf`、`~/.gitconfig`。
4. 分析内容 — 查找工具集成（nvm、conda、brew 代码块）、自定义函数、PATH 添加。
5. 备份目标文件，然后写入扫描到的配置。
6. 如需要则创建 `~/.bashrc_local`。

**重要：** "当前机器"指 Claude 运行所在的机器（用户调用 setup 的机器）。
如果用户在配置一台*远程*服务器，他们需要提供文件或使用 dotfiles 仓库。
上下文不明确时询问确认。

---

## 通用：备份（所有模式）

覆盖前始终备份：

```bash
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
for f in ~/.bashrc ~/.bash_aliases ~/.vimrc ~/.tmux.conf ~/.gitconfig; do
    if [ -f "$f" ]; then
        cp "$f" "${f}.bak.${TIMESTAMP}"
        echo "已备份 $f → ${f}.bak.${TIMESTAMP}"
    fi
done
```

## 通用：确保目录存在

```bash
mkdir -p ~/.local/bin
mkdir -p ~/.config
```

## 禁止操作

- 不要自动运行 `source ~/.bashrc` — 在最后提醒用户即可。
- 不要在未备份的情况下静默覆盖。
- 不要在未经用户确认的情况下运行 dotfiles 仓库中的安装脚本。
