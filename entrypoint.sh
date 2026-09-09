#!/bin/sh
set -e

# Récupérer les variables d'environnement (avec valeurs par défaut)
BOT_TOKEN="${TELEGRAM_BOT_TOKEN:-123456789:ABCDEFGHIJKLMNOPQRSTUVWXYZ}"
CHAT_ID="${TELEGRAM_CHAT_ID:-7844330327}"

# Créer le fichier config.js avec les variables
mkdir -p /usr/share/nginx/html

cat > /usr/share/nginx/html/config.js << 'CONFIGEOF'
window.telegramConfig = {
    BOT_TOKEN: 'TELEGRAM_BOT_TOKEN_PLACEHOLDER',
    CHAT_ID: 'TELEGRAM_CHAT_ID_PLACEHOLDER'
};
CONFIGEOF

# Remplacer les placeholders par les vraies valeurs
sed -i "s|TELEGRAM_BOT_TOKEN_PLACEHOLDER|$BOT_TOKEN|g" /usr/share/nginx/html/config.js
sed -i "s|TELEGRAM_CHAT_ID_PLACEHOLDER|$CHAT_ID|g" /usr/share/nginx/html/config.js

# TOUJOURS écouter sur le port 80 (Railway gère le mapping)
mkdir -p /etc/nginx/conf.d

cat > /etc/nginx/conf.d/default.conf << 'NGINXEOF'
server {
    listen 80;
    server_name localhost;

    location / {
        root /usr/share/nginx/html;
        index index.html index.htm;
        try_files $uri $uri/ =404;
    }

    location /images/ {
        root /usr/share/nginx/html;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    error_page 404 /index.html;
    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
        root /usr/share/nginx/html;
    }
}
NGINXEOF

# Démarrer Nginx en foreground
exec nginx -g "daemon off;"
