#!/bin/bash

# Variables
NGINX_DIR="/etc/nginx"
NGINX_SERVICE="nginx"

# Function to check if NGINX is already installed
check_nginx_installed() {
    if command -v $NGINX_SERVICE > /dev/null; then
        echo "NGINX is already installed."
        exit 1
    fi
}

# Function to install NGINX
install_nginx() {
    echo "Updating package lists..."
    sudo apt update

    echo "Installing NGINX..."
    sudo apt install -y $NGINX_SERVICE
}

# Function to check if the default configuration file exists
check_nginx_conf() {
    if [ -f "$NGINX_DIR/nginx.conf" ]; then
        echo "NGINX configuration file already exists."
        exit 1
    fi
}

# Function to configure NGINX
configure_nginx() {
    echo "Creating default configuration file..."
    cat <<EOL | sudo tee $NGINX_DIR/nginx.conf
worker_processes auto;
events {
    worker_connections 1024;
}
http {
    sendfile on;
    keepalive_timeout 65;
    server {
        listen 8090;
        server_name localhost;

        location / {
            root /var/www/html;
            index index.html index.htm;
        }
    }
}
EOL
}

# Function to start NGINX
start_nginx() {
    echo "Starting NGINX service..."
    sudo systemctl start $NGINX_SERVICE
    sudo systemctl enable $NGINX_SERVICE
    echo "NGINX has been started and enabled to run on boot."
}

# Main Script Execution
check_nginx_installed
install_nginx
check_nginx_conf
configure_nginx
start_nginx

echo "NGINX installation and configuration completed successfully!"