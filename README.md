# apache-server

My notes on running an apache server in Ubuntu.

There are several advantages for using a nativily installed apache instead of a docker container.

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

Apache needs full access to all parent folders leading yo your intended document root or it will error. 

If you want apache to use projects your working on from your home directory without handing out
too many permisisons create a symbolic link instea.

```shell
sudo ln -s ~/websites /var/www/html # try to use fully qualified paths in all links.
ls -al /var/www/html #should now show your websites folder
```
Your project folders will now appear inside the apache html folder that is already owned by 

## Setting permissions.

Good practice is to use 755.

755 give the owner read write and execute, groups get read and execute,
 and others (like apache) get read and execute.
```shell
chmod -R 755 ~/websites
```
ALl files created afterwards should inherit the permissions and apache should be fine to read them.
Only give write access to sepcific folders when you actually need it.

## Setting up vhosts.

In ubuntu the typical appraoch is to use a symbolic link to config files in the
`sites-enabled` folder.

```shell
ls -al /etc/apache2/sites-enabled/
```

### Unlink vhost.
By default there will be a link to 000-default.conf lets remove it...
```shell
sudo unlink /etc/apache2/sites-enabled/000-default.conf
```

### Link new vhost.

Lets link the [dynamic localhost](dynamic-localhost.conf) config I have provided...

```shell
# do not use reletive paths when linking files. Thats why I add pwd insead of ./
sudo ln -s $(pwd)/dynamic-localhost.conf /etc/apache2/sites-enabled
sudo cat /etc/apache2/sites-enabled # make sure the link worked.
```

### Restart apache

Enable the new config by restarting. Need to do this evey time you change stuff.

```SHELL
sudo service apache2 restart
```

## Dynamic Localhost
If you used my provided dynamic localhot config you can now access sub folders via a
sub domain.

EXAMPLE: hello-world.localhost will open websites/hello-world

It goes 2 levels deep.
EXAMPLE: project.cate.localhost will open websites/world/hello