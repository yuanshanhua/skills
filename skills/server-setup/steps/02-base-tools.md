# 基础工具探测与安装

## 基础工具可用性探测

在任何需要系统包管理器的阶段之前，先快速探测关键工具是否已安装：

```bash
echo "正在检测基础工具..."
MISSING_TOOLS=()
for cmd in git curl wget vim tar gzip; do
    if ! command -v "$cmd" &>/dev/null; then
        MISSING_TOOLS+=("$cmd")
    fi
done

# 检查编译工具链
HAS_GCC=false
HAS_MAKE=false
command -v gcc &>/dev/null && HAS_GCC=true
command -v make &>/dev/null && HAS_MAKE=true
```

## 向用户汇报并由用户决定

不要自动执行 `apt-get update && apt-get install`。而是将探测结果告知用户，
让他们决定如何处理：

```
基础工具检测结果:
  ✅ 已安装: git, tar, gzip, ...
  ❌ 未安装: curl, wget, ...
  🔧 编译工具: gcc [有/无], make [有/无]

以下后续步骤可能需要这些缺失的工具:
  - Homebrew 安装需要: curl (或 wget), git, gcc, make
  - Nix 安装需要: curl (或 wget)
  - fzf (git clone 方式) 需要: git

是否现在通过系统包管理器安装这些缺失的工具？
（需要 sudo 权限，将执行 apt-get update / dnf update）
```

用户可能的回答：
- **"是"** → 仅安装缺失的工具，不做全量 upgrade
- **"不需要"** → 跳过，后续步骤中如果遇到缺失工具会相应跳过并报告
- **"我自己来"** → 暂停，等用户手动安装后继续

## 按需安装（仅在用户同意后执行）

### Debian 系列
```bash
sudo apt-get update
sudo apt-get install -y ${MISSING_TOOLS[@]}
# 如果需要编译工具链:
# sudo apt-get install -y build-essential
```

### RHEL 系列
```bash
sudo $PKG_MGR update -y
sudo $PKG_MGR install -y ${MISSING_TOOLS[@]}
# 如果需要编译工具链:
# sudo $PKG_MGR groupinstall -y "Development Tools"
```

## 注意事项

- **不做全量 upgrade** — `apt-get upgrade -y` 耗时长且可能引入意外变更，
  用户完全可以自己执行
- **只装缺失的** — 已经存在的工具不重复安装
- **不是必跑阶段** — 如果用户选择了 Homebrew/Nix 作为首选包管理器，且所有
  前置依赖都已就绪，这个文件可能完全不需要执行
