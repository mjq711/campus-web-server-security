#!/bin/bash
# SSL证书配置与验证脚本
# 功能：安装系统默认证书工具，验证证书可用性
# 执行权限：root用户（sudo -i）

echo "=== 开始SSL证书配置与验证 ==="

# 1. 安装系统默认证书工具
echo "Step 1/3：安装ssl-cert工具..."
apt install -y ssl-cert  # Ubuntu系统自带自签名证书工具

# 2. 验证证书文件存在性
echo "Step 2/3：验证证书文件..."
CERT_PUB="/etc/ssl/certs/ssl-cert-snakeoil.pem"  # 证书公钥路径
CERT_KEY="/etc/ssl/private/ssl-cert-snakeoil.key" # 证书私钥路径

if [ -f "$CERT_PUB" ] && [ -f "$CERT_KEY" ]; then
    echo "✅ 证书文件存在："
    ls -l $CERT_PUB
    ls -l $CERT_KEY
else
    echo "❌ 证书文件缺失，自动生成..."
    make-ssl-cert generate-default-snakeoil --force-overwrite
fi

# 3. 验证证书有效性
echo "Step 3/3：验证证书信息..."
openssl x509 -in $CERT_PUB -noout -subject -dates

echo "=== SSL证书配置验证完成 ==="
echo "证书公钥路径：$CERT_PUB"
echo "证书私钥路径：$CERT_KEY"