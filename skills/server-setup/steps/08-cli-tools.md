# Phase 8: CLI 生产力工具

安装用户选定的工具。工具列表来源（按优先级）：

1. **`CUSTOM_TOOLS`** — 用户提供的列表（来自 Q&A 文本、文件路径、
   或从 dotfiles 仓库的 `packages.txt` / `Brewfile` 自动检测）
2. **Q&A 清单选择** — Q&A 中的标准复选框列表
3. **空** — 用户未选择任何工具 → 跳过此阶段

**各工具的具体安装指令、安装后配置、镜像设置等**，统一存放在 `tools/<tool_name>.md` 中。
安装某个工具前，读取对应的文件获取详细步骤。

## 工具目录

```
tools/
├── fzf.md           模糊查找器
├── ripgrep.md       递归正则搜索 (rg)
├── fd.md            现代 find 替代 (fd-find)
├── bat.md           语法高亮 cat 替代
├── eza.md           现代 ls 替代
├── zoxide.md        智能 cd
├── yazi.md          终端文件管理器
├── pueue.md         后台任务队列
├── tmux.md          终端复用器
├── btop.md          系统监控
├── homebrew.md      Homebrew (Linuxbrew) 包管理器
├── nix.md           Nix 包管理器
├── docker.md        Docker Engine + Compose + 换源 + 用户组
└── podman.md        Podman + Compose + 换源 + Rootless
```

## 安装策略：尊重用户的包管理器偏好

安装顺序和方式取决于 `PREFERRED_PKG_MANAGER`：

### 当 `PREFERRED_PKG_MANAGER` 已设置（如 `brew`、`nix`）

1. **首先安装首选包管理器。** 这是此阶段的最高优先动作。
   读取 `tools/homebrew.md` 或 `tools/nix.md` 获取安装指令。
2. **通过首选管理器安装所有其他选定的工具。** 对每个工具尝试
   `brew install <name>` 或 `nix-env -iA nixpkgs.<name>`（或所选管理器的
   对应命令）。
3. **如果某个工具无法通过首选管理器安装，跳过它。** 不要回退到
   `apt-get`/`dnf`、`cargo install` 或任何其他方式。用户选择特定包管理器
   是有原因的 — 通常是为了避免 sudo、获取更新版本、或维护一致的包生态。
   静默回退到系统包管理器会破坏这些目标。
4. **容器运行时例外：** Docker 和 Podman 即使在首选 brew/nix 时，
   仍建议通过系统包管理器/官方仓库安装（涉及系统服务和内核特性）。
   安装前向用户说明原因。
5. **安装完成后总结报告** 呈现清晰的总结：

   ```
   ✅ 已通过 brew 安装: fzf, ripgrep, fd, bat, eza, zoxide, btop, tmux
   ⏭️  无法通过 brew 安装（已跳过）: yazi, pueue

   这些工具需要你来决定如何安装:
     - yazi: 需要 cargo install --locked yazi-fm yazi-cli
     - pueue: 需要 cargo install --locked pueue

   是否要用其他方式安装这些工具？
   ```

   让用户决定。他们可能说 "用 cargo 装那些" 或 "跳过" 或 "我稍后处理"。
   跟随他们的指示。

### 当 `PREFERRED_PKG_MANAGER` 为 `none`（默认）

使用各工具文件（`tools/<tool_name>.md`）中标注的推荐安装方式。
推荐方式通常是能获取最新版本且尽量不需要 sudo 的方式：

- 基于 git 的安装（fzf）
- 官方安装脚本（zoxide）
- cargo install（yazi、pueue、eza）
- go install
- ...
- 系统包管理器作为最后手段，仅用于仓库中打包良好的工具
  （tmux、ripgrep、fd、bat、btop）

## 处理自定义工具列表

如果设置了 `CUSTOM_TOOLS`，解析并对每个工具分类：

- **已知工具**（在下方工具矩阵或 `tools/` 中有对应文件）：
  读取 `tools/<tool_name>.md` 获取安装方式，按 `PREFERRED_PKG_MANAGER` 策略执行。
- **未知工具**：如果设置了首选包管理器，尝试通过该管理器安装。
  如果为 `none`，跳过并报告 — 不要用 `apt-get install` 猜测。

## 依赖检查

通过推荐方式安装时，部分工具需要 Rust 工具链（cargo）：
- **yazi**、**pueue**、**eza** — 通过 `cargo install` 安装

这仅在 `PREFERRED_PKG_MANAGER=none` 时适用。如果用户偏好 brew 或 nix，
这些工具可能有预编译的包（不需要 Rust）。如果不可用而被跳过，总结中会告知用户。

使用默认安装方式时：如果选择了这些工具但 Phase 7 中未安装 Rust，先安装 Rust
（按 `steps/07-dev-environments.md` 中的 Rust 章节）。

## 工具安装矩阵

下表为快速参考，显示各安装方式的可用性。
**具体安装命令和步骤请查阅 `tools/<tool_name>.md`。**

| 工具 | brew | nix | apt/dnf | cargo | 其他 |
|------|------|-----|---------|-------|------|
| fzf | ✅ | ✅ | ✅（旧版） | — | git clone（推荐） |
| ripgrep | ✅ | ✅ | ✅ | ✅ | — |
| fd | ✅ | ✅ | ✅ | ✅ | — |
| bat | ✅ | ✅ | ✅ | ✅ | — |
| eza | ✅ | ✅ | — | ✅ | — |
| zoxide | ✅ | ✅ | — | ✅ | 安装脚本（推荐） |
| yazi | ✅ | ✅ | — | ✅ | — |
| pueue | ✅ | ✅ | — | ✅ | — |
| tmux | ✅ | ✅ | ✅ | — | — |
| btop | ✅ | ✅ | ✅（22.04+） | — | — |
| Homebrew | — | — | — | — | 官方脚本 |
| Nix | — | — | — | — | 官方脚本 |
| Docker | ⚠️ | ⚠️ | ✅ | — | 官方脚本（推荐） |
| Podman | ⚠️ | ✅ | ✅ | — | — |

> ⚠️ = 可安装但建议通过系统包管理器/官方仓库安装（涉及系统服务和内核特性）

## 安装后配置

安装工具后，按需将 shell 集成添加到 `~/.bashrc_local`。
各工具的安装后步骤详见对应的 `tools/<tool_name>.md`。
