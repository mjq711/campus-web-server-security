#!/bin/bash
# Nginx HTTPS配置脚本
# 功能：配置Nginx支持HTTPS，关联SSL证书
# 执行权限：root用户（sudo -i）

echo "=== 开始Nginx HTTPS配置 ==="

# 1. 安装Nginx（若未安装）
echo "Step 1/4：安装Nginx..."
apt install -y nginx

# 2. 清理旧配置文件
echo "Step 2/4：清理旧配置..."
rm -f /etc/nginx/sites-available/default 2>/dev/null
rm -f /etc/nginx/sites-enabled/default 2>/dev/null

# 3. 复制新配置文件
echo "Step 3/4：配置HTTPS..."
CONFIG_SRC="../config_files/nginx_default.conf"
CONFIG_DST="/etc/nginx/sites-available/default"

# 若配置文件不存在，直接创建
if [ -f "$CONFIG_SRC" ]; then
    cp $CONFIG_SRC $CONFIG_DST
else
    # 直接生成配置文件
    cat > $CONFIG_DST << 'EOF'
server {
    listen 80;
    listen 443 ssl;
    ssl_certificate /etc/ssl/certs/ssl-cert-snakeoil.pem;
    ssl_certificate_key /etc/ssl/private/ssl-cert-snakeoil.key;
    root /var/www/html;
    index index.html;
    location / {
        try_files $uri $uri/ =404;
    }
}
EOF
fi

# 4. 测试配置并重启Nginx
echo "Step 4/4：启动Nginx服务..."
nginx -t 2>/dev/null  # 测试配置语法
if [ $? -eq 0 ]; then
    systemctl restart nginx
    echo "✅ Nginx重启成功，HTTPS服务已启用"
    systemctl status nginx --no-pager | grep "active"
else
    echo "❌ Nginx配置有误，请检查配置文件"
fi

echo "=== Nginx HTTPS配置完成 ==="
echo "HTTPS访问地址：https://192.168.56.101"