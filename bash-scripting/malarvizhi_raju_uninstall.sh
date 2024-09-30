#Stopping the Nginx application to uninstall the Nginx
sudo systemctl stop nginx
#uninstalling Nginx with purge
sudo apt-get purge nginx
#removing any dependency files
sudo apt-get autoremove
#removing the files and directories created for nginx
sudo rm -rf /etc/nginx /var/log/nginx
#checking status of Nginx to see that it does not exist
sudo systemctl status nginx
