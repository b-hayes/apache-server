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

Use this to check for error messages when something doesn'St go right.

```shell
sudo tail -f /var/log/apache2/error.log
```

## Folder Permissions
By default, the www folder is owned by root, lets change it to you and www-data group.

Use my script:
```shell
./fix-permissions.sh
```
This should set all the bitmask flags so that any new files created by either oyu or apache should be
fully accessible by both of you.

## Setting up vhosts.

Use a symbolic link to place config files in the `sites-enabled` folder.
The configs are lot more forgiving with permission it only needs read access.

```shell
ls -al /etc/apache2/sites-enabled/
```

### Unlink vhost config.
By default there will be a link to 000-default.conf lets remove it...
```shell
sudo unlink /etc/apache2/sites-enabled/000-default.conf
```

### Link new vhost config.

Use my [dynamic localhost](dynamic-localhost.conf) config if you don't have your own yet.

```shell
# do not use relative paths when linking files. That's why I use $(pwd) instead of ./
sudo ln -s $(pwd)/dynamic-localhost.conf /etc/apache2/sites-enabled
```
Verify the contents of the file are there via the new link.
```shell
sudo cat /etc/apache2/sites-enabled/dynamic-localhost.conf
```

### Restart apache

Enable the new config by restarting. Need to do this evey time you change stuff.

```SHELL
sudo service apache2 restart
```

## The Dynamic Localhost config.
The dynamic localhost config will point subdomains to sub folders.
Up to two level deep eg:
- localhost points to /var/www/html
- animals.localhost points to /var/www/html/animals
- dogs.animals.localhost points to websites/animals/dogs

So you can have all your projects share the same native instance of apache/php/mysql etc.
No need to.

Remember that all these folders are also accessible via localhost/paths.
EG: cats.localhost ==  localhost/cats
So you will want to add a htaccess file preventing direct folder access if you only want it accessed by subdomain.

## Exposing to the public?

Rather than .localhost being last .com or .net will be so the folder will match the main domain name.

- animals.com points to /var/www/html/animals
- cat.animals.com points to /var/www/html/animals/cats

The beauty of this is your public site eg animals.com is also accessed via animals.localhost allowing you
to debug your production version with some special flags enabled for localhost only.

However, .com.au or alike and www. will throw a spanner in the works and you will need to make rules for those cases.


