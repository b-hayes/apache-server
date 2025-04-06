#!/bin/bash

DEFAULT_FOLDER="/var/www/"
FOLDER=${1:-$DEFAULT_FOLDER}

# Set ownership to your user and www-data group
sudo chown -R $USER:www-data "$FOLDER"

# Set permissions for existing files, user and group, but no others.
sudo chmod -R 770 "$FOLDER"

# Set setgid bit to inherit group ownership for new files
sudo chmod -R g+s "$FOLDER"

# Set default permissions for new directories
sudo setfacl -d -R -m u:$USER:rwx "$FOLDER"
sudo setfacl -d -R -m g:www-data:rwx "$FOLDER"
sudo setfacl -d -R -m o:--- "$FOLDER"
