#!/bin/bash

# Check if NGINX is installed
if [ ! -e /usr/sbin/nginx ]; then
    sudo apt-get install -y nginx
else
    echo "NGINX is already installed. Please remove the existing installation before running this script again."
    exit 1
fi

# Check if NGINX is running
if [ ! -e /var/run/nginx.pid ]; then
    sudo service nginx start
else
    echo "NGINX is already running. Please stop the existing instance before running this script again."
    exit 1
fi

# Check if NGINX is configured to start on boot
if [ ! -e /etc/rc.d/rc0.d/S20nginx ]; then
    sudo update-rc.d nginx defaults
else
    echo "NGINX is already configured to start automatically on boot."
fi

# Modify the default NGINX configuration
if [ ! -e /etc/nginx/sites-available/default ]; then
    sudo sed -i 's/yourservername/localhost/g' /etc/nginx/sites-available/default
else
    echo "The default NGINX configuration file already exists. Please remove or modify it before running this script again."
    exit 1
fi

# Restart NGINXls
sudo service nginx restart