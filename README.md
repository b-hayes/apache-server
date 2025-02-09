# apache-server

My notes on running an apache server in Ubuntu.

## Installation.

```shell
sudo apt update
sudo apt upgrade
sudo apt install apache2
sudo apt install php
sudo a2enmod rewrite
sudo service apache2 restart
```

Check if php is working:

```shell
echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/phpinfo.php
xdg-open http://localhost/phpinfo.php
```

## Checking for errors.

Use this to check for error messages when something doesnt go right.

```shell
sudo tail -f /var/log/apache2/error.log
```

## Permissions

Apache needs full access to all parent folders leading yo your intended document root or it will error. Its not enough to just have permissions for the folder you specify.

To avoid handing out too many permissions create a symbolic link instead.

```shell
sudo ln -s ~/myProjects/websites/ /var/www/html/
```
Your project folders will now appear inside the apache html folder that is already owned by 

## Setting permissions.

Good practice is to use 755.

755 give the owner read write and execute, groups get read and execute,
 and others (like apache) get read and execute.
```shell
chmod -R 755 ~/myProjects/websites/.
```
ALl files created afterwards should inherit the permissions and apache should be fine to read them.
Only give write access to sepcific folders when you actually need it.