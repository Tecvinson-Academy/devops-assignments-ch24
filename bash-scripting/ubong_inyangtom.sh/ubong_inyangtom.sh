#!/bin/bash

# This script automates the installation and configuration of NGINX
:
# Function to output messages
log_message() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"
}

# Update package list
log_message "Updating package list..."
if sudo apt-get update; then
    log_message "Package list updated successfully."
else
    log_message "Failed to update package list. Exiting..."
    exit 1
fi

# Check if NGINX is already installed
if command -v nginx >/dev/null 2>&1; then
    log_message "NGINX is already installed. Skipping installation."
else
    log_message "Installing NGINX..."
    if sudo apt-get install -y nginx; then
        log_message "NGINX installed successfully."
    else
        log_message "Failed to install NGINX. Exiting..."
        exit 1
    fi
fi

# Start NGINX service
log_message "Starting NGINX service..."
if sudo systemctl start nginx; then
    log_message "NGINX service started successfully."
else
    log_message "Failed to start NGINX service. Exiting..."
    exit 1
fi

# Enable NGINX to start at boot
log_message "Enabling NGINX to start on boot..."
if sudo systemctl enable nginx; then
    log_message "NGINX enabled to start on boot."
else
    log_message "Failed to enable NGINX on boot."
fi

# Create a simple HTML file for testing
HTML_FILE="/var/www/html/index.html"
log_message "Creating a test HTML file at $HTML_FILE..."
if [ -f "$HTML_FILE" ]; then
    log_message "Test HTML file already exists at $HTML_FILE. Skipping creation."
else
    sudo bash -c "echo '<!DOCTYPE html><html><head><title>NGINX Test</title></head><body><h1>NGINX is working!</h1></body></html>' > $HTML_FILE"
    log_message "Test HTML file created successfully."
fi

# Check NGINX configuration for syntax errors
log_message "Checking NGINX configuration for syntax errors..."
if sudo nginx -t; then
    log_message "NGINX configuration is valid."
else
    log_message "NGINX configuration has errors. Exiting..."
    exit 1
fi

# Reload NGINX to apply any changes
log_message "Reloading NGINX..."
if sudo systemctl reload nginx; then
    log_message "NGINX reloaded successfully."
else
    log_message "Failed to reload NGINX."
    exit 1
fi

log_message "NGINX installation and configuration completed successfully."
exit 0
