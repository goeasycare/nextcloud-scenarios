#!/bin/sh
set -e

# Path to Nextcloud config
CONFIG_PATH="/var/www/html/config/config.php"

# Check if config exists, if not, copy a default or wait for installation
if [ ! -f "$CONFIG_PATH" ]; then
    echo "Config file not found. Nextcloud might need installation."
fi

# Fix permissions on startup
# Nextcloud needs data and config to be writable by www-data
echo "Fixing permissions..."
chown -R www-data:www-data /var/www/html/config
chown -R www-data:www-data /var/www/html/data
chown -R www-data:www-data /var/www/html/apps
chown -R www-data:www-data /var/www/html/themes

# Start PHP-FPM
exec "$@"
