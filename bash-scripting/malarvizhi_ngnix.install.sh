#!/bin/bash
#updating Advanced package Tool ( apt ) to update the package index files
sudo apt update
#upgrading the apt to upgrade the actual packages installed in the system.
#update and upgrade is to make sure system is upto date with latest package releases
sudo apt upgrade -y
#To remove the dependency files that are availablle in the system when an application got uninstalled
sudo apt autoremove -y
#Installing the Nginx
sudo apt install nginx
#firewall to allow Nginx http
#sudo ufw allow 'Nginx HTTP'
#sudo ufw status

#To check the status of Nginx to see if it is started or not
sudo systemctl status nginx
#To identify the IP Address of the system to access the web application
curl -4 icanhazip.com
