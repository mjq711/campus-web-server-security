#!/bin/bash
# 安全状态监控脚本
# 功能：汇总防火墙规则、开放端口、服务状态、证书有效期
# 执行权限：root用户（sudo -i）
# 定期执行：可添加到crontab（例如每日凌晨执行：0 0 * * * /path/04_security_monitor.sh）

echo "===== 校园Web服务器安全状态报告 ====="
echo "生成时间: $(date)"
echo "服务器IP: $(hostname -I | awk '{print $1}')"
echo "===================================="

# 1. 防火墙规则（显示核心5条）
echo -e "\n1. 核心防火墙规则："
iptables -L -n | grep -E "(ACCEPT|DROP)" | head -5

# 2. 开放端口（监听状态）
echo -e "\n2. 监听端口状态："
if command -v netstat &> /dev/null; then
    netstat -tulpn 2>/dev/null | grep LISTEN | head -3
else
    echo "⚠️ 未安装netstat，执行 apt install -y net-tools 可查看详细端口"
    ss -tulpn 2>/dev/null | grep LISTEN | head -3
fi

# 3. 核心服务状态
echo -e "\n3. 核心服务状态："
NGINX_STATUS=$(systemctl is-active nginx 2>/dev/null || echo "未运行")
SSH_STATUS=$(systemctl is-active ssh 2>/dev/null || echo "未运行")
echo "Nginx（HTTPS）: $NGINX_STATUS"
echo "SSH（远程管理）: $SSH_STATUS"

# 4. SSL证书有效期
echo -e "\n4. SSL证书有效期："
CERT_PUB="/etc/ssl/certs/ssl-cert-snakeoil.pem"
if [ -f "$CERT_PUB" ]; then
    openssl x509 -in $CERT_PUB -noout -dates 2>/dev/null
else
    echo "⚠️ SSL证书文件缺失"
fi

echo -e "\n===================================="