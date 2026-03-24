# Phase 6: 时区与语言环境

## 设置时区

```bash
sudo timedatectl set-timezone "$TIMEZONE"
```

默认：`Asia/Shanghai`

验证：
```bash
timedatectl
```

## 设置语言环境

### Debian 系列

```bash
# 按需安装 locale
sudo apt-get install -y locales

# 生成 locale
sudo locale-gen "$LOCALE"
sudo update-locale LANG="$LOCALE" LC_ALL="$LOCALE"
```

### RHEL 系列

```bash
# 按需安装语言包（如 zh_CN）
sudo $PKG_MGR install -y glibc-langpack-zh 2>/dev/null || true

sudo localectl set-locale LANG="$LOCALE"
```

默认语言环境：`zh_CN.UTF-8`

## 验证

```bash
locale
date
```
