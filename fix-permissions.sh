#!/bin/bash

# Set ownership to your user and www-data group
sudo chown -R $USER:www-data /var/www/

# Set permissions to 775 (rwx for user and group, rx for others)
sudo chmod -R 775 /var/www/

# Set setgid bit to inherit group ownership for new files
sudo chmod -R g+s /var/www/

# Set default permissions for new files
sudo setfacl -d -m u:$USER:rwx /var/www/
sudo setfacl -d -m g:www-data:rwx /var/www/
sudo setfacl -d -m o:--- /var/www/
