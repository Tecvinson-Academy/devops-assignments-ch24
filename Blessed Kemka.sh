#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Update package list and install NGINX
install_nginx() {
    echo "Updating package list..."
    sudo apt-get update -y

    echo "Installing NGINX..."
    sudo apt-get install nginx -y
}

# Check if NGINX is already installed
if command_exists nginx; then
    echo "NGINX is already installed."
else
    install_nginx
fi

# Create a backup of the default NGINX configuration file if it exists
if [ -f /etc/nginx/nginx.conf ]; then
    echo "Backing up existing NGINX configuration file..."
    sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
fi

# Create a new NGINX configuration file
echo "Creating new NGINX configuration file..."
sudo tee /etc/nginx/nginx.conf > /dev/null <<EOL
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
    worker_connections 768;
}

http {
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;

    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    gzip on;
    gzip_disable "msie6";

    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
}
EOL

# Create a symbolic link for the new configuration
if [ ! -L /etc/nginx/sites-enabled/default ]; then
    echo "Creating symbolic link for the new configuration..."
    sudo ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/
fi

# Test NGINX configuration
echo "Testing NGINX configuration..."
sudo nginx -t

# Reload NGINX to apply the new configuration
if [ $? -eq 0 ]; then
    echo "Reloading NGINX..."
    sudo systemctl reload nginx
else
    echo "NGINX configuration test failed. Please check the configuration file."
fi

echo "NGINX installation and configuration completed successfully."
