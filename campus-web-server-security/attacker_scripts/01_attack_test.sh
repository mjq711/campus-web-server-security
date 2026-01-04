#!/bin/bash
# 攻击机核心测试脚本
# 功能：连通性测试、端口扫描、危险端口拦截测试、HTTPS验证
# 执行权限：普通用户（需sudo时输入密码）

# 定义靶机IP（固定）
TARGET=192.168.56.101
echo "=== 攻击机测试脚本 - 靶机IP：$TARGET ==="

# 1. 连通性测试
echo -e "\n1. 网络连通性测试（ping）："
ping -c 5 $TARGET
if [ $? -eq 0 ]; then
    echo "✅ 靶机网络连通正常"
else
    echo "❌ 靶机网络不通，请检查网络配置"
    exit 1
fi

# 2. 加固前端口扫描（保存基线）
echo -e "\n2. 加固前端口扫描（基线评估）："
sudo nmap -sS $TARGET -oN scan_before.txt
echo "开放端口："
cat scan_before.txt | grep "open"

# 3. 加固后端口扫描（对比测试）
echo -e "\n3. 加固后端口扫描（效果验证）："
sudo nmap -sS $TARGET -oN scan_after.txt
echo "开放端口："
cat scan_after.txt | grep "open"

# 4. 危险端口拦截测试（FTP 21 + Telnet 23）
echo -e "\n4. 危险端口拦截测试："
echo "=== FTP端口（21）测试："
sudo nmap -p 21 $TARGET
echo "=== Telnet端口（23）测试："
sudo nmap -p 23 $TARGET

# 5. HTTPS加密访问验证
echo -e "\n5. HTTPS加密访问验证："
echo "=== HTTPS服务可用性："
curl -k https://$TARGET 2>/dev/null | head -5
if [ $? -eq 0 ]; then
    echo "✅ HTTPS服务可正常访问"
else
    echo "❌ HTTPS服务访问失败"
fi

echo -e "\n=== SSL证书信息："
curl -k -v https://$TARGET 2>&1 | grep -A3 "SSL certificate" | head -10

# 6. HTTP明文传输验证（可选）
echo -e "\n6. HTTP明文传输验证："
curl http://$TARGET 2>/dev/null | head -3

echo -e "\n=== 测试完成 ==="
echo "测试报告文件：scan_before.txt（加固前）、scan_after.txt（加固后）"