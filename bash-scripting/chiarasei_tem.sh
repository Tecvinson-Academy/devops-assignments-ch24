#!/bin/bash

function install_nginx() {
    if ! command -v nginx &> /dev/null; then
        sudo apt-get update
        sudo apt-get install nginx -y
        echo "NGINX installed successfully."
    else
        echo "NGINX is already installed."
    fi
}

function create_default_server_block() {
    if ! grep -q '^server {.*}' /etc/nginx/sites-enabled/default; then
        sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
        echo "Default server block created."
    else
        echo "Default server block already exists."
    fi
}

function start_nginx() {
    sudo systemctl start nginx
    sudo systemctl enable nginx
    if ! systemctl is-active --quiet nginx; then
        echo "Error: NGINX failed to start."
        exit 1
    else
        echo "NGINX started successfully."
    fi
}

# Main script execution
install_nginx
create_default_server_block
start_nginx