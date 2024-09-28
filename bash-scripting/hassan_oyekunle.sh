#!/bin/bash 
 
cd ~ 

# Check if nginx is installed
if [ -f /usr/sbin/nginx ]; then
    echo "Application is already installed"
else
    sudo apt update
    sudo apt install -y nginx
    echo "nginx is installed successfully"
fi
#####################################################################

# Check if nginx.conf file exists
if [ -f nginx.conf ]; then
    echo "nginx.conf file already exists"
else
    sudo cp /etc/nginx/nginx.conf /home/hassan
    echo "nginx.conf file has been copied successfully"
fi
##########################################################

# Check if nginx_backup directory exists
if [ -d nginx_backup ]; then
    echo "nginx_backup directory already exists"
else
    mkdir nginx_backup
    echo "nginx_backup directory created successfully"
fi
#################################################################

# Move and rename the nginx.conf file to the backup directory
sudo mv nginx.conf nginx_backup/nginx.conf-$(date +"%y-%m-%d-%H-%M-%S")
echo "Successfully backed up nginx.conf with date $(date +"%y-%m-%d-%H-%M-%S")"

############################################################################
