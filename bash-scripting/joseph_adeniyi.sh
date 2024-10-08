#!/bin/bash

# Function to handle errors
handle_error() {
  echo "Error: $1"
  exit 1
}

# Check if NGINX is installed
if ! command -v nginx > /dev/null 2>&1; then
  echo "NGINX is not installed. Installing..."
  sudo apt-get update && sudo apt-get install -y nginx || handle_error "Failed to install NGINX."
else
  echo "NGINX is already installed."
fi

# Check if NGINX is running
if ! pidof nginx > /dev/null; then
  echo "Starting NGINX..."
  sudo service nginx start || handle_error "Failed to start NGINX."
else
  echo "NGINX is already running."
fi

# Check if NGINX is configured to start on boot
if ! systemctl is-enabled nginx | grep -q "enabled"; then
  echo "Configuring NGINX to start on boot..."
  sudo systemctl enable nginx || handle_error "Failed to enable NGINX to start on boot."
else
  echo "NGINX is already configured to start on boot."
fi

# Modify the default NGINX configuration
DEFAULT_CONF="/etc/nginx/sites-available/default"

if [ -f "$DEFAULT_CONF" ]; then
  echo "Modifying the default NGINX configuration..."
  sudo sed -i 's/yourservername/localhost/g' "$DEFAULT_CONF" || handle_error "Failed to modify NGINX configuration."
else
  echo "Default NGINX configuration file does not exist."
  handle_error "Missing NGINX configuration file."
fi

# Check NGINX configuration syntax
echo "Testing NGINX configuration..."
sudo nginx -t || handle_error "NGINX configuration test failed."

# Restart NGINX to apply changes
echo "Restarting NGINX..."
sudo service nginx restart || handle_error "Failed to restart NGINX."

echo "NGINX installation and configuration complete."

