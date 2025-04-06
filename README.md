# apache-server

My notes on running a native apache server in Ubuntu.

If all your websites can use the same version of php and mysql I find it easier to just use a single
instance of those services instead of spinning up multiple docker containers.

You can use a single vhost with htaccess rules to direct each website and subdomain of to a separate folder.

This is mainly great for development testing on localhost as all project folders can be accessed,
via a subdomain.

It can also be a great setup for production preventing you form needing to create a vhosts config for every website.

## Installing Apache 2.

```shell
sudo apt update
sudo apt upgrade
sudo apt install apache2
sudo apt install php
sudo a2enmod rewrite # enable htaccess rewrite module
```

Restart apache:
```shell
sudo service apache2 restart
```

Check if php is working:

```shell
echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/phpinfo.php
xdg-open http://localhost/phpinfo.php
```

If php is working and you see the php info page best to delete this file if your setting up a production server.
```shell
sudo rm /var/www/html/phpinfo.php
```

## Checking for errors.

Use this to check for error messages.

```shell
sudo tail -f /var/log/apache2/error.log
```

## Folder Permissions
By default, the www folder is owned by root, lets change it to you and www-data group.
We are using the /var/www/html folder now but best to do it for the entire /var/www folder as well.

Use my fix permissions script:
```shell
./fix-permissions.sh
```
This should set all the bitmask flags so that any new files created by either you or apache should be
fully accessible by both of you.

Many of the commands I have later in this readme rely on the bitmasks to be set this way.

## Remove the default page.
Right now the default page is exposing sensitive information and should be removed from production servers.

Even if you remove the default site config the default page will still be shown if something goes wrong.

You can test this theory by removing the default site, and refreshing tha page.

The sites enabled folder contains symbolic links to config files that enable each website.
You could just `sudo unlink /etc/apache2/sites-enabled/000-default.conf` or you can use the helper command
`a2dissite` command like so:

```shell
sudo a2dissite 000-default.conf
```

Now restart apache again:
```shell
sudo service apache2 restart
```

Now refresh http://localhost and you will still see the default page!

There are other deeper configs still pointing to that /var/www/html folder as the document root even with the
default vhost config disabled. We could edit core configs but I prefer to just get rid of the html file.

Lets just move it so you can still read it later if you want, it does have some interesting info.
```shell
mv /var/www/html/index.html ~/ubuntu-default-page.html
```

And then add some generic maintenance message jic something goes wrong and the default folder is served again.

For now just copy the example:
```shell
cp maintenance.php /var/www/html/index.php
```

## Setting up vhosts.

Normally you would create your vhosts configs in `/etc/apache2/sites-available/` and then use the `a2ensite` command
to create symlinks to the sites-enabled folder when ready.

But were just going to manually link configs from this repo.

### Adding vhost config from this repo.

Use my [dynamic localhost](dynamic-localhost.conf) config to start with. This one is manly designed for dev testing.

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
The dynamic localhost config will point subdomains to sub folders 
so you dont have to make a vhost for every app you are working on.

It maps up to two subdomains deep:
- localhost points to /var/www/html
- animals.localhost points to /var/www/html/animals
- dogs.animals.localhost points to websites/animals/dogs

So you can have all your projects share the same native instance of apache/php/mysql etc.
No need to.

Remember that all these folders are also accessible via localhost/paths.
EG: cats.localhost ==  localhost/cats
So you will want to add a htaccess file preventing direct folder access if you only want it accessed by subdomain.

## Exposing to the public?

Rather than .localhost being last .com or .net will be so the folder will still match the main domain name.

- animals.com points to /var/www/html/animals
- cat.animals.com points to /var/www/html/animals/cats

The beauty of this is your public site eg animals.com is also accessed via animals.localhost allowing you
to debug your production version with some special flags enabled for localhost only.

However, .com.au or alike and www. will throw a spanner in the works and you will need to make rules for those cases.


## Changing the default port.
You may decide to use a proxy manager in front of your web services and thus
need to change the port for apache.

```shell
sudo nano /etc/apache2/ports.conf
```
Change the listen ports to something that won't clash with common ports for other systems.
