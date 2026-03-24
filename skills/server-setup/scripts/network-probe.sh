#!/usr/bin/env bash
# network-probe.sh — 探测国际网络连通性，10 秒内必须完成
# 输出格式: 自然语言报告，方便 LLM 直接阅读理解
# 退出码: 0=完成
#
# 探测项目:
#   1. PyPI (pypi.org) HTTPS 连通性及响应时间
#   2. GitHub HTTPS 连通性及响应时间
#   3. TUNA 清华镜像 HTTPS 连通性及响应时间

set -euo pipefail

BUDGET=10  # 总时间预算（秒）
PROBE_START=$(date +%s)

# --- 辅助函数 ---
budget_left() {
    local elapsed=$(( $(date +%s) - PROBE_START ))
    [ $elapsed -lt $BUDGET ]
}

# --- 检测可用的 HTTP 工具 ---
if command -v curl &>/dev/null; then
    HTTP_TOOL="curl"
elif command -v wget &>/dev/null; then
    HTTP_TOOL="wget"
else
    HTTP_TOOL="ping_only"
fi

# --- 初始化结果变量 ---
PYPI_STATUS="未测试"
PYPI_TIME=""
GITHUB_STATUS="未测试"
GITHUB_TIME=""
TUNA_STATUS="未测试"
TUNA_TIME=""

# --- Test 1: PyPI HTTPS 连通性 ---
case "$HTTP_TOOL" in
    curl)
        PYPI_TIME=$(curl -so /dev/null -w '%{time_total}' --connect-timeout 3 --max-time 4 https://pypi.org 2>/dev/null) && PYPI_STATUS="可达" || PYPI_STATUS="不可达"
        ;;
    wget)
        WGET_START_PYPI=$(date +%s)
        if wget -q --timeout=4 --tries=1 -O /dev/null https://pypi.org 2>/dev/null; then
            PYPI_STATUS="可达"
        else
            PYPI_STATUS="不可达"
        fi
        WGET_END_PYPI=$(date +%s)
        PYPI_TIME="$(( WGET_END_PYPI - WGET_START_PYPI ))"
        ;;
    ping_only)
        if ping -c 1 -W 3 151.101.0.223 &>/dev/null; then
            PYPI_STATUS="仅 ping 可达（无法验证 HTTPS）"
        else
            PYPI_STATUS="不可达"
        fi
        ;;
esac

# --- 检查剩余预算 ---
if budget_left; then
    case "$HTTP_TOOL" in
        curl)
            GITHUB_TIME=$(curl -so /dev/null -w '%{time_total}' --connect-timeout 3 --max-time 4 https://github.com 2>/dev/null) && GITHUB_STATUS="可达" || GITHUB_STATUS="不可达"

            if budget_left; then
                TUNA_TIME=$(curl -so /dev/null -w '%{time_total}' --connect-timeout 3 --max-time 4 https://mirrors.tuna.tsinghua.edu.cn 2>/dev/null) && TUNA_STATUS="可达" || TUNA_STATUS="不可达"
            else
                TUNA_STATUS="超时跳过"
            fi
            ;;
        wget)
            WGET_START=$(date +%s)
            if wget -q --timeout=4 --tries=1 -O /dev/null https://github.com 2>/dev/null; then
                GITHUB_STATUS="可达"
            else
                GITHUB_STATUS="不可达"
            fi
            WGET_END=$(date +%s)
            GITHUB_TIME="$(( WGET_END - WGET_START ))"

            if budget_left; then
                WGET_START2=$(date +%s)
                if wget -q --timeout=4 --tries=1 -O /dev/null https://mirrors.tuna.tsinghua.edu.cn 2>/dev/null; then
                    TUNA_STATUS="可达"
                else
                    TUNA_STATUS="不可达"
                fi
                WGET_END2=$(date +%s)
                TUNA_TIME="$(( WGET_END2 - WGET_START2 ))"
            else
                TUNA_STATUS="超时跳过"
            fi
            ;;
        ping_only)
            if ping -c 1 -W 3 140.82.121.4 &>/dev/null; then
                GITHUB_STATUS="仅 ping 可达（无法验证 HTTPS）"
            else
                GITHUB_STATUS="不可达"
            fi

            if budget_left; then
                if ping -c 1 -W 3 101.6.15.130 &>/dev/null; then
                    TUNA_STATUS="仅 ping 可达（无法验证 HTTPS）"
                else
                    TUNA_STATUS="不可达"
                fi
            else
                TUNA_STATUS="超时跳过"
            fi
            ;;
    esac
fi

# --- 格式化响应时间 ---
format_time() {
    local status="$1" time_val="$2"
    if [ "$status" = "可达" ] && [ -n "$time_val" ]; then
        echo "${time_val}s"
    else
        echo ""
    fi
}

PYPI_TIME_FMT=$(format_time "$PYPI_STATUS" "$PYPI_TIME")
GITHUB_TIME_FMT=$(format_time "$GITHUB_STATUS" "$GITHUB_TIME")
TUNA_TIME_FMT=$(format_time "$TUNA_STATUS" "$TUNA_TIME")

# --- 输出可读报告 ---
echo "===== 网络连通性探测报告 ====="
echo ""
echo "探测工具: $HTTP_TOOL"
echo ""
echo "--- 探测结果 ---"
if [ -n "$PYPI_TIME_FMT" ]; then
    echo "PyPI (pypi.org):             $PYPI_STATUS，响应时间 $PYPI_TIME_FMT"
else
    echo "PyPI (pypi.org):             $PYPI_STATUS"
fi
if [ -n "$GITHUB_TIME_FMT" ]; then
    echo "GitHub (github.com):        $GITHUB_STATUS，响应时间 $GITHUB_TIME_FMT"
else
    echo "GitHub (github.com):        $GITHUB_STATUS"
fi
if [ -n "$TUNA_TIME_FMT" ]; then
    echo "TUNA 镜像 (tsinghua.edu.cn): $TUNA_STATUS，响应时间 $TUNA_TIME_FMT"
else
    echo "TUNA 镜像 (tsinghua.edu.cn): $TUNA_STATUS"
fi
echo "============================="
