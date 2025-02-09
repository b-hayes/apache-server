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

## Folder Permissions

Its best to just create projects inside the /var/www/html folder. Its too finicky otherwise.

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
The dynamic localhost config will point sub domains to sub folders.

localhost still points to /var/www/html but now
animals.localhost will open website in /var/www/html/animals
It goes 2 levels deep eg: dogs.animals.localhost will open websites/animals/dogs

So you can practice having mutiple domains with sub domains all living unther the master domain of localhost.

This can easily transfer to a self hosted setup with real domains later.