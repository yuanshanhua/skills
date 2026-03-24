# Phase 4: Git 全局配置

配置 git 用户身份和合理的默认设置。

## 必要输入

来自 Q&A：
- `GIT_USER_NAME` — 用户提交时的姓名
- `GIT_USER_EMAIL` — 用户提交时的邮箱

如果 Q&A 中未提供，在继续之前立即询问。

## 配置

```bash
git config --global user.name "$GIT_USER_NAME"
git config --global user.email "$GIT_USER_EMAIL"

# 合理的默认值
git config --global init.defaultBranch main
git config --global core.editor vim
git config --global core.autocrlf input
git config --global pull.rebase false
git config --global push.autoSetupRemote true
git config --global fetch.prune true

# 实用别名
git config --global alias.st "status -sb"
git config --global alias.lg "log --oneline --graph --decorate --all"
git config --global alias.last "log -1 HEAD --stat"
git config --global alias.unstage "reset HEAD --"

# 凭证存储
git config --global credential.helper store
```

## 验证

```bash
git config --global --list
```
