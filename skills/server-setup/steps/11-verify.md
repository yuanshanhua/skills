# Phase 11: 验证与总结

最后一个步骤。检查所有已安装的内容并呈现简洁的总结。

## 验证

对每个应该已安装的工具/服务，检查可用性：

```bash
check_tool() {
    local name="$1"
    local cmd="$2"
    if command -v "$cmd" &>/dev/null; then
        local version=$("$cmd" --version 2>&1 | head -1)
        echo "  ✅ $name: $version"
    else
        echo "  ❌ $name: 未找到"
    fi
}
```

对所有已安装的组件运行检查：

```bash
echo "=== 已安装工具 ==="
check_tool "git" "git"
check_tool "vim" "vim"
check_tool "curl" "curl"
# ...（对每个已安装的工具）

echo ""
echo "=== 开发环境 ==="
# 仅检查选定的
check_tool "conda" "conda"
check_tool "uv" "uv"
check_tool "node" "node"
check_tool "go" "go"
check_tool "rustc" "rustc"
check_tool "java" "java"

echo ""
echo "=== 服务 ==="
if systemctl is-active docker &>/dev/null; then
    echo "  ✅ Docker: 运行中"
else
    echo "  ⚠️  Docker: 未运行"
fi
```

## 总结表

呈现 markdown 表格展示结果：

```
| 阶段 | 状态 | 备注 |
|------|------|------|
| Dotfiles | ✅ | 已备份原文件 |
| Git 配置 | ✅ | user: xxx, email: xxx |
| SSH | ✅/⏭️ | 已生成密钥 / 已跳过 |
| 时区 | ✅ | Asia/Shanghai |
| 镜像源 | ✅/⏭️ | TUNA 镜像 / 直连 |
| 开发环境 | ✅ | conda, nvm |
| CLI 工具 | ✅ | fzf, rg, bat |
| Docker | ✅/⏭️ | 运行中 / 已跳过 |
| 防火墙 | ✅/⏭️ | 端口 22,80,443 / 已跳过 |
```

## 失败项

如果有步骤出现失败，清晰列出：

```
⚠️ 设置过程中出现以下问题:
  - 工具 'xxx' 安装失败
  - ...
```

## 后续提醒

始终提醒用户：

1. **应用 shell 配置：** 运行 `source ~/.bashrc` 或打开新终端
2. **Docker 组：** 如果加入了 docker 组，需注销并重新登录
3. **SSH 密钥：** 如果已生成，公钥在 `~/.ssh/id_ed25519.pub` — 添加到 GitHub/GitLab
4. **SSH 端口变更：** 如果修改了端口，更新 SSH 客户端配置
5. **bashrc_local：** 机器特定的自定义可添加到 `~/.bashrc_local`
6. **备份：** 原始配置文件已备份，后缀为 `.bak.TIMESTAMP`
