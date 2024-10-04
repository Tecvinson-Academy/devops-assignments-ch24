#!/bin/bash

# Script: firstname_lastname.sh
# Description: A simple script to install and configure NGINX on a Linux system

# Function to check if the user is root
check_root() {
    if [ "$(id -u)" != "0" ]; then
        echo "You must run this script as root or use sudo."
        exit 1
    fi
}

# Function to install NGINX
install_nginx() {
    if ! command -v nginx &> /dev/null; then
        echo "NGINX not found. Installing NGINX..."
        apt update
        apt install -y nginx
        echo "NGINX installed successfully."
    else
        echo "NGINX is already installed."
    fi
}

# Function to configure NGINX
configure_nginx() {
    # Check if the default configuration file exists
    CONFIG_FILE="/etc/nginx/sites-available/default"
    if [ -f "$CONFIG_FILE" ]; then
        echo "Backing up the default NGINX configuration..."
        cp "$CONFIG_FILE" "${CONFIG_FILE}.bak"
        echo "Backup completed. Configuring NGINX..."
        
        # Modify the default NGINX configuration file 
        echo "
        server {
            listen 80;
            server_name localhost;
            root /var/www/html;

            location / {
                try_files \$uri \$uri/ =404;
            }
        }
        " > "$CONFIG_FILE"
        
        echo "NGINX configuration updated."
    else
        echo "NGINX configuration file not found."
        exit 1
    fi
}

# Function to start and enable NGINX service
start_nginx() {
    echo "Starting and enabling NGINX service..."
    systemctl start nginx
    systemctl enable nginx
    echo "NGINX is now running."
}

# Function to check NGINX status
check_nginx_status() {
    echo "Checking NGINX status..."
    systemctl status nginx | grep "active (running)"
    if [ $? -eq 0 ]; then
        echo "NGINX is running successfully."
    else
        echo "NGINX failed to start. Please check the logs."
    fi
}

# Main script execution
check_root
install_nginx
configure_nginx
start_nginx
check_nginx_status

echo "NGINX installation and configuration completed."
