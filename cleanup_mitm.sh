#!/bin/bash

# cleanup_mitm.sh - 恢复 MITM 测试环境

echo "=== 开始恢复 MITM 测试环境 ==="

# 检查是否以 root 权限运行
if [ "$EUID" -ne 0 ]; then
    echo "请使用 sudo 运行此脚本: sudo ./cleanup_mitm.sh"
    exit 1
fi

echo "1. 停止 mitmweb 进程..."
# 查找并杀死 mitmweb 进程
pkill -f "mitmweb.*8084"
if [ $? -eq 0 ]; then
    echo "   ✓ mitmweb 进程已停止"
else
    echo "   ℹ 未找到运行的 mitmweb 进程"
fi

echo "2. 清理 iptables NAT 规则..."
# 清空 NAT 表的所有规则
iptables -t nat -F
if [ $? -eq 0 ]; then
    echo "   ✓ NAT 表规则已清空"
else
    echo "   ✗ 清理 NAT 规则失败"
    exit 1
fi

echo "3. 关闭 IP 转发..."
# 关闭 IP 转发
echo 0 > /proc/sys/net/ipv4/ip_forward
if [ $? -eq 0 ]; then
    echo "   ✓ IP 转发已关闭"
else
    echo "   ✗ 关闭 IP 转发失败"
    exit 1
fi

echo "4. 验证清理结果..."
echo "   === 当前 NAT 表规则 ==="
iptables -t nat -L -n

echo "   === IP 转发状态 ==="
ip_forward_status=$(cat /proc/sys/net/ipv4/ip_forward)
echo "   /proc/sys/net/ipv4/ip_forward = $ip_forward_status"

echo "5. 检查端口占用..."
# 检查 8084 端口是否仍在监听
if netstat -tlnp | grep :8084 > /dev/null; then
    echo "   ⚠ 端口 8084 仍在监听，可能需要手动处理"
    netstat -tlnp | grep :8084
else
    echo "   ✓ 端口 8084 已释放"
fi

echo ""
echo "=== 环境恢复完成 ==="
echo "现在你的网络环境应该恢复正常了。"
echo "可以测试手机 APP 是否能重新连接 IoT 设备。"
