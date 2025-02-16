#!/bin/bash

# Set ownership to your user and www-data group
sudo chown -R $USER:www-data /var/www/

# Set permissions for existing files, user and group, but no others.
sudo chmod -R 770 /var/www/

# Set setgid bit to inherit group ownership for new files
sudo chmod -R g+s /var/www/

# Set default permissions for new directories
sudo setfacl -d -R -m u:$USER:rwx /var/www/
sudo setfacl -d -R -m g:www-data:rwx /var/www/
sudo setfacl -d -R -m o:--- /var/www/
