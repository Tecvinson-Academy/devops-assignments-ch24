#!/bin/bash

# Update package index
echo "Updating package index..."
if sudo apt update; then
    echo "Package index updated successfully."
else
    echo "Failed to update package index."
    exit 1
fi

# Install NGINX
echo "Installing NGINX..."
if sudo apt install -y nginx; then
    echo "NGINX installed successfully."
else
    echo "Failed to install NGINX."
    exit 1
fi

# Allow NGINX through the firewall
echo "Allowing NGINX through the firewall..."
if sudo ufw allow 'Nginx HTTP'; then
    echo "Firewall rule added successfully."
else
    echo "Failed to add firewall rule."
    exit 1
fi

# Create a basic configuration file
echo "Creating NGINX configuration file..."
if sudo tee /etc/nginx/sites-available/default > /dev/null <<EOL
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;

    server_name _;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOL
then
    echo "Configuration file created successfully."
else
    echo "Failed to create configuration file."
    exit 1
fi

# Enable the configuration by creating a symbolic link
echo "Enabling NGINX configuration..."
if sudo ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/; then
    echo "Configuration enabled successfully."
else
    echo "Failed to enable configuration."
    exit 1
fi

# Test the configuration and restart NGINX
echo "Testing NGINX configuration..."
if sudo nginx -t; then
    echo "Configuration test passed."
    echo "Restarting NGINX..."
    if sudo systemctl restart nginx; then
        echo "NGINX restarted successfully."
    else
        echo "Failed to restart NGINX."
        exit 1
    fi
else
    echo "Configuration test failed."
    exit 1
fi

echo "NGINX installation and configuration complete."
