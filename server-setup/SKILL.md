---
name: server-setup
description: >
  全自动 Linux 服务器环境搭建，用于开发和部署。
  部署个性化 shell 配置（bashrc、aliases、PS1 提示符）、常用工具，
  以及可选的开发环境（conda、uv、nvm、Docker 等），一次对话完成。
  当用户提到搭建新服务器、配置新 Linux 机器、初始化开发环境、初始化 VPS/云实例、
  或迁移 dotfiles 到新主机时，使用此 skill。也适用于用户说
  "我刚拿到一台新服务器"、"帮我配一下这台机器"、"配置开发环境"、
  "初始化这台 Linux"等场景。支持 Ubuntu/Debian 和 CentOS/RHEL/TencentOS 系列。
---

# Server Setup Skill

自动化完成一台全新 Linux 服务器的完整搭建 — 从系统配置到个性化 shell 环境 —
让用户在一次会话中从裸机到可用的开发环境。

## 交互语言

默认使用**中文**与用户交互（包括 Q&A 清单、进度提示、错误报告、最终总结等）。
如果用户使用英文提问或明确要求英文，则切换为英文。

## 设计理念

每个开发者的服务器配置都是**通用基础**（git、curl、时区）与**个人偏好**（shell 提示符、
别名、常用工具）的混合。此 skill 两者兼顾：它提供一个可靠的阶段化框架，同时允许用户指定自定义来源的
**具体配置内容**（dotfiles、工具列表等）。

每个步骤的详细指令存放在 `steps/` 下的独立文件中。只在确定需要执行该步骤时才读取
对应文件 — 以此保持上下文精简。

## 内容与框架的分离

此 skill 将**做什么**（框架 — 阶段、顺序、发行版检测、镜像设置、验证）
与**部署什么**（内容 — dotfiles、工具列表、开发环境选择）分开。这意味着：

- `references/` 目录附带一套**默认配置** — 精心调校的 dotfiles 和工具列表，开箱即用。
- 用户可以**覆盖**这些配置：提供自己的 dotfiles git 仓库、自定义工具列表、内联配置，
  甚至 "扫描我当前机器的配置"。

框架保持不变，只有内容部分可替换。

### 用户自定义来源的工作方式

在 Q&A 开始时，会询问用户是使用内置默认还是提供自己的配置。有三种模式：

| 模式 | Dotfiles 来源 | 工具列表来源 |
|------|--------------|-------------|
| **内置默认** | `references/bashrc.sh` + `references/bash_aliases.sh` | Q&A 中的标准清单 |
| **Dotfiles 仓库** | 克隆用户仓库，使用其中的文件（见下文） | 用户自行指定列表 |
| **扫描当前机器** | 读取当前 `~/.bashrc` 和 `~/.bash_aliases` 并复制 | 从已安装的工具中提取列表 |

**Dotfiles 仓库规范：** 当用户提供 git 仓库 URL 时，克隆到临时目录并查找配置文件。
支持常见的 dotfiles 仓库布局：

```
# 扁平布局：文件在仓库根目录
dotfiles/
├── .bashrc
├── .bash_aliases
├── .vimrc
├── .tmux.conf
└── ...

# Stow 布局：按工具分组
dotfiles/
├── bash/
│   ├── .bashrc
│   └── .bash_aliases
├── vim/
│   └── .vimrc
├── tmux/
│   └── .tmux.conf
└── install.sh          ← 如存在则询问是否运行
```

如果仓库根目录有 `install.sh` 或 `setup.sh`，先查看内容再询问用户是否运行。
否则逐个部署识别到的配置文件，并做好备份。

### 自定义工具列表

当用户提供自己的工具列表（通过 Q&A 文本、dotfiles 仓库中的文件如 `packages.txt`
或 `Brewfile`），解析并用它来驱动 Phase 7 和 Phase 8，替代默认清单。支持的格式：

- 纯文本，每行一个工具（如 `fzf\nripgrep\nbat`）
- `Brewfile`（提取包名）
- dotfiles 仓库中的 `packages.txt` / `tools.txt`
- JSON 数组（如 `["fzf", "ripgrep", "bat"]`）

对于内置安装矩阵（`references/cli_tools.md`）中未识别的工具：
如果设置了首选包管理器，尝试通过该管理器安装。否则跳过，并在最终总结中报告给用户
由其决定。不要静默回退到系统包管理器 — 它通常需要 sudo 且版本较旧，
不符合大多数用户的期望。

## 架构：步骤文件

```
steps/
├── 00-detect-distro.md        Phase 0 — 始终首先运行
├── 01-mirror-sources.md       Phase 1 — 网络探测 + 镜像配置
├── 02-base-tools.md           Phase 2 — 基础工具探测与按需安装
├── 03-dotfiles.md             Phase 3 — bashrc / bash_aliases / dotfiles 仓库
├── 04-git-config.md           Phase 4 — git 全局配置
├── 05-ssh.md                  Phase 5 — SSH 密钥 + 安全加固
├── 06-timezone-locale.md      Phase 6 — 时区与语言环境
├── 07-dev-environments.md     Phase 7 — conda / uv / nvm / Go / Rust / Java
├── 08-cli-tools.md            Phase 8 — fzf, ripgrep, yazi 等
├── 09-docker.md               Phase 9 — Docker Engine + Compose
├── 10-firewall.md             Phase 10 — ufw / firewalld
└── 11-verify.md               Phase 11 — 验证与总结
```

其他参考文件（按需由步骤文件加载）：
```
references/
├── bashrc.sh                  默认 .bashrc 模板
├── bash_aliases.sh            默认 .bash_aliases 模板
└── cli_tools.md               各工具按发行版的安装指令
```

## 全局上下文

以下变量在早期阶段建立，影响所有后续步骤：

- **`DISTRO_FAMILY`**（`debian` 或 `rhel`）— 发行版系列, 决定包管理器和包名
- **`USE_MIRROR`**（`true` 或 `false`）— 是否使用国内镜像源。Phase 1 配置
  系统包管理器（apt/dnf）镜像，其他工具的镜像（pip、conda、npm、cargo、Go、
  Docker、Homebrew 等）在各自安装步骤中配置
- **`CONFIG_SOURCE`**（`builtin` | `repo:<url>` | `scan`）— dotfiles 和配置的来源
- **`CUSTOM_TOOLS`**（列表，可选）— 用户提供的工具列表，覆盖默认清单
- **`PREFERRED_PKG_MANAGER`**（`none` | `brew` | `nix` | 其他）— 用户首选的
  CLI 工具安装方式。设置为非 `none` 时，会先安装该包管理器，再用它安装
  所有其他选定的 CLI 工具。无法通过首选管理器安装的工具会被**跳过**（不会静默回退
  到系统包管理器），并在最后报告给用户决定。

这些变量分别在 Phase 0、Phase 1 和 Q&A 中设定。后续每个安装软件的步骤文件
都应检查 `USE_MIRROR` 并相应调整下载 URL。

**自动检测包管理器偏好：** 解析用户的 CLI 工具列表（来自 Q&A 或 `CUSTOM_TOOLS`）时，
如果列表中包含包管理器（Homebrew、Nix 等），主动询问用户是否希望用它作为首选安装器。
明确选择 Nix 或 Homebrew 的用户通常偏好通过统一的生态管理所有工具，以保持一致性
和版本新鲜度。

---

## 执行流程

### Phase 0: 检测发行版与环境 — `steps/00-detect-distro.md`

| | |
|---|---|
| **内容** | 读取 `/etc/os-release`，分类为 `debian` 或 `rhel` 系列，设置包管理器 |
| **时机** | 始终执行 — 这是第一个步骤 |
| **条件** | 无（无条件执行） |

→ 读取 `steps/00-detect-distro.md` 并执行。

---

### Phase 1: 网络探测与镜像源 — `steps/01-mirror-sources.md`

| | |
|---|---|
| **内容** | 探测网络连通性（ping Google、测试 PyPI/GitHub 直连），推荐是否使用国内镜像，然后配置 apt/dnf 系统包管理器镜像。其他工具（pip、conda、npm、cargo、Go、Docker、Homebrew 等）的镜像在各自安装阶段配置 |
| **时机** | 始终探测；仅在用户确认后应用镜像（或自动检测建议） |
| **条件** | 无条件运行探测。如果探测显示国际连通性差，推荐 `USE_MIRROR=true`，向用户展示结果并让其确认 |
| **影响** | 此决定影响**后续所有下载操作** |

→ 读取 `steps/01-mirror-sources.md` 并执行。

---

### Phase 1.5: Q&A 配置清单

在执行后续阶段之前，向用户展示整合的 Q&A 清单。清单涵盖后续所有阶段所需的决策，
让用户一次性回答。Phase 1 的镜像源探测结果应已整合在内。

**第一个问题应该是关于配置来源** — 这决定了后续问题的措辞（例如，如果用户有
dotfiles 仓库，工具列表问题会变成 "仓库之外还需要什么额外工具？"）。

以中文呈现此清单（根据语境自然调整措辞）：

```
开始之前，先确认几个配置：

0. 配置来源 — Shell 配置（bashrc、aliases 等）从哪里来？
   a) 使用内置默认配置（精心调校的 PS1、git 别名、实用函数等）
   b) 从你的 dotfiles 仓库克隆 — 请粘贴 git URL:
   c) 扫描当前机器的配置并复制

   💡 提示: 如果你有 GitHub/GitLab dotfiles 仓库（如 github.com/you/dotfiles），
   选 (b) 会克隆并部署其中的配置文件。仓库中也可以放 packages.txt 或 Brewfile
   来指定工具列表。

1. Git 配置
   - 用户名:
   - 邮箱:

2. 时区（默认: Asia/Shanghai）:
3. 语言环境（默认: zh_CN.UTF-8）:

4. SSH 设置
   a) 生成新的 SSH 密钥对？[y/n]
   b) 禁用密码登录？[y/n]
   c) 修改 SSH 端口？[默认: 22]

5. 开发环境（可多选）:
   [ ] Python — conda (Miniconda)
   [ ] Python — uv
   [ ] Node.js — nvm
   [ ] Go
   [ ] Rust (rustup)
   [ ] Java (OpenJDK, 版本: 11/17/21)

6. CLI 工具（可多选，或指定自己的列表）:
   [ ] yazi    [ ] pueue    [ ] fzf      [ ] ripgrep
   [ ] fd      [ ] bat      [ ] eza      [ ] zoxide
   [ ] tmux    [ ] Homebrew [ ] btop     [ ] Nix
   或: 粘贴列表 / 提供文件路径 / "使用 dotfiles 仓库中的 packages.txt"

6b. 包管理器偏好
    如果你选了 Homebrew、Nix 等包管理器，或者有其他偏好的包管理器，
    可以用它来统一安装上面的所有 CLI 工具 — 通常能拿到更新的版本，
    且不需要 sudo。
    首选包管理器:
      a) 无 — 每个工具用各自推荐的方式安装
      b) Homebrew — 尽可能通过 brew 安装
      c) Nix — 尽可能通过 nix 安装
      d) 其他: ___________

7. Docker — 安装 Docker Engine + Compose？[y/n]
   将当前用户加入 docker 组？[y/n]

8. 防火墙 — 是否配置？[y/n]
   开放端口（如 22,80,443）:

9. 还有其他需求吗？
```

**处理配置来源答案：**

- **选项 (a) — 内置默认：** 设置 `CONFIG_SOURCE=builtin`。Phase 3 将使用
  `references/bashrc.sh` 和 `references/bash_aliases.sh`。
- **选项 (b) — dotfiles 仓库：** 设置 `CONFIG_SOURCE=repo:<url>`。在 Phase 3
  中克隆仓库并扫描其中的配置文件和可选工具列表。
- **选项 (c) — 扫描当前机器：** 设置 `CONFIG_SOURCE=scan`。读取当前的
  `~/.bashrc` 和 `~/.bash_aliases`，分析并复制到目标机器。

收集完答案后，简要总结计划，然后按阶段逐步执行。

---

### Phase 2: 基础工具探测（按需） — `steps/02-base-tools.md`

| | |
|---|---|
| **内容** | 探测 git、curl、wget、gcc 等基础工具是否已安装，向用户汇报缺失项 |
| **时机** | 始终探测 |
| **行为** | 只探测和汇报，不自动执行 `apt-get update` 或全量 `upgrade`。由用户决定是否安装缺失工具、是否需要 sudo |

→ 在需要时读取 `steps/02-base-tools.md`，探测并向用户汇报。用户同意后才安装缺失项。

---

### Phase 3: Shell 配置（Dotfiles） — `steps/03-dotfiles.md`

| | |
|---|---|
| **内容** | 根据 `CONFIG_SOURCE` 部署 shell 配置：内置默认、用户的 dotfiles 仓库、或从当前机器扫描 |
| **时机** | 始终执行 |
| **条件** | 无（必执行）。覆盖前先备份。 |

→ 读取 `steps/03-dotfiles.md` 并执行。行为因 `CONFIG_SOURCE` 而异：
- `builtin`：使用 `references/bashrc.sh` 和 `references/bash_aliases.sh`
- `repo:<url>`：克隆仓库，查找并部署配置文件，检查工具列表
- `scan`：读取当前机器的 shell 配置并复制

---

### Phase 4: Git 全局配置 — `steps/04-git-config.md`

| | |
|---|---|
| **内容** | 设置 git user.name、user.email、默认分支、编辑器、实用别名 |
| **时机** | 始终执行（git 是必备工具） |
| **条件** | 需要 Q&A 中的 user.name 和 user.email。如果未提供，此时询问。 |

→ 读取 `steps/04-git-config.md` 并执行。

---

### Phase 5: SSH 密钥与安全加固 — `steps/05-ssh.md`

| | |
|---|---|
| **内容** | 生成 ed25519 SSH 密钥，可选加固 sshd_config（禁用密码登录、修改端口） |
| **时机** | 仅在用户在 Q&A 中选择时执行 |
| **条件** | `ssh_generate_key == true` 或 `ssh_disable_password == true` 或 `ssh_port != 22` |

→ 满足条件时，读取 `steps/05-ssh.md` 并执行。否则跳过。

---

### Phase 6: 时区与语言环境 — `steps/06-timezone-locale.md`

| | |
|---|---|
| **内容** | 设置系统时区和语言环境 |
| **时机** | 始终执行 |
| **条件** | 使用 Q&A 中的时区和语言环境（默认：Asia/Shanghai，zh_CN.UTF-8） |

→ 读取 `steps/06-timezone-locale.md` 并执行。

---

### Phase 7: 开发环境 — `steps/07-dev-environments.md`

| | |
|---|---|
| **内容** | 安装选定的开发工具：conda、uv、nvm+Node、Go、Rust、Java |
| **时机** | 仅在用户选择了任意开发环境时执行 |
| **条件** | Q&A 中至少选择了一个开发环境 |
| **镜像影响** | 如果 `USE_MIRROR=true`，为 conda channels、pip index、npm registry、Go proxy、rustup mirror 等配置镜像（镜像配置包含在此步骤文件中） |

→ 满足条件时，读取 `steps/07-dev-environments.md`，仅执行选定的子节。

---

### Phase 8: CLI 生产力工具 — `steps/08-cli-tools.md`

| | |
|---|---|
| **内容** | 安装选定的 CLI 工具（fzf、ripgrep、fd、bat、eza、yazi、pueue、zoxide、tmux、Homebrew、Nix、btop） |
| **时机** | 仅在用户选择了任意 CLI 工具时执行（来自 Q&A 清单、自定义列表或 dotfiles 仓库） |
| **条件** | 至少选择了一个 CLI 工具，或 `CUSTOM_TOOLS` 非空 |
| **策略** | 如果设置了 `PREFERRED_PKG_MANAGER`，先安装该管理器，然后专用它安装所有其他工具。无法通过首选管理器安装的工具**跳过并报告** — 不要静默回退到 apt/dnf |

→ 满足条件时，读取 `steps/08-cli-tools.md` 并执行。同时参考 `references/cli_tools.md`
获取各工具的详细安装指令。如果用户提供了自定义工具列表（通过文本、文件或 dotfiles 仓库），
使用该列表替代默认清单。

---

### Phase 9: Docker — `steps/09-docker.md`

| | |
|---|---|
| **内容** | 安装 Docker Engine + Docker Compose 插件，可选将用户加入 docker 组 |
| **时机** | 仅在用户选择时执行 |
| **条件** | `docker_install == true` |
| **镜像影响** | 如果 `USE_MIRROR=true`，使用国内 Docker registry 镜像 |

→ 满足条件时，读取 `steps/09-docker.md` 并执行。

---

### Phase 10: 防火墙 — `steps/10-firewall.md`

| | |
|---|---|
| **内容** | 配置 ufw（Debian）或 firewalld（RHEL），开放指定端口 |
| **时机** | 仅在用户选择时执行 |
| **条件** | `firewall_setup == true` |

→ 满足条件时，读取 `steps/10-firewall.md` 并执行。

---

### Phase 11: 验证与总结 — `steps/11-verify.md`

| | |
|---|---|
| **内容** | 验证所有已安装的工具，显示版本，列出失败项，提醒用户后续操作 |
| **时机** | 始终执行 — 最后一个步骤 |
| **条件** | 无（无条件执行） |

→ 读取 `steps/11-verify.md` 并执行。

---

## 错误处理

- 每个阶段应独立检查错误。非关键性失败记录日志；关键性失败（无法更新包、没有 sudo）停下来询问用户。
- 维护一个警告/失败的累积列表，在 Phase 11 中报告。
- 运行 `sudo` 前先验证权限。如果没有权限，列出哪些步骤需要 root 并询问用户。

## 重要原则

- **幂等性**：可安全多次运行。安装前检查，覆盖前备份。
- **不静默覆盖**：始终备份现有配置文件。
- **bashrc_local**：机器特定的配置（工具集成、PATH 添加）放在 `~/.bashrc_local`，保持主 bashrc 可移植。
- **延迟加载**：仅在即将执行某步骤时才读取其文件。不要预先加载所有文件到上下文中。
