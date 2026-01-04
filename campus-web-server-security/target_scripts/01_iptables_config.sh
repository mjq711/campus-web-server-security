#!/bin/bash
# 校园Web服务器iptables防火墙配置脚本
# 功能：默认拒绝入站流量，仅开放必要端口，规则持久化
# 执行权限：root用户（sudo -i）

echo "=== 开始配置iptables防火墙 ==="

# 1. 清理现有规则
echo "Step 1/5：清理现有规则..."
iptables -F
iptables -X

# 2. 设置默认策略（入站/转发拒绝，出站允许）
echo "Step 2/5：设置默认策略..."
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# 3. 配置白名单规则
echo "Step 3/5：配置白名单规则..."
iptables -A INPUT -i lo -j ACCEPT  # 允许本地回环通信
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT  # 允许已建立连接
iptables -A INPUT -p tcp --dport 22 -j ACCEPT  # SSH远程管理端口
iptables -A INPUT -p tcp --dport 80 -j ACCEPT  # HTTP服务端口
iptables -A INPUT -p tcp --dport 443 -j ACCEPT  # HTTPS加密服务端口
iptables -A INPUT -p icmp -j ACCEPT  # 允许ping测试（网络诊断）

# 4. 规则持久化（重启后生效）
echo "Step 4/5：持久化规则..."
apt install -y netfilter-persistent  # 安装持久化工具（若未安装）
netfilter-persistent save

# 5. 验证配置结果
echo "Step 5/5：验证规则配置..."
iptables -L -n -v --line-numbers

echo "=== iptables防火墙配置完成 ==="
echo "核心说明：仅开放22/80/443端口及ICMP协议，默认拒绝所有其他入站流量"