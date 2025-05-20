# Apache-server

My notes on running a native Apache server in Ubuntu.

I use the same version of PHP and MySQL for most apps and find it easier to just use a single
instance of those services instead of creating multiple docker containers.

Using a single Virtual Host with ht access rules to direct each website to a separate folder.
If the folder exists, the website is enabled, simple as that.

For local development you can just use subdomains of localhost as long as you use Cloudflare DNS on your machine.

It can also be a great setup for production, preventing you from needing to create a Virtual Host config for every website.

## Installing Apache 2.

```shell
sudo apt update
sudo apt upgrade
sudo apt install apache2

# install php and php mod for apache
sudo apt install php8.3 libapache2-mod-php8.3
# install common php extensions.
sudo apt install php8.3-{cgi,mysql,curl,xsl,gd,common,xml,zip,xsl,soap,bcmath,mbstring,gettext,imagick}
sudo a2enmod php8.3

sudo a2enmod rewrite # enable htaccess rewrite module
```

Restart Apache:
```shell
sudo service apache2 restart
```

Check if you see the default web page: http://localhost

Check if PHP is working:
```shell
echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/phpinfo.php
xdg-open http://localhost/phpinfo.php
```

If PHP is not working, check out this debug session[duck.ai_2025-04-06_23-58-47.txt](duck.ai_2025-04-06_23-58-47.txt) I had with an AI.

If PHP is working, and you see the PHP info page best to delete this file if your setting up a production server.
```shell
sudo rm /var/www/html/phpinfo.php
```

## Checking for Apache errors.

Use this to check for error messages.

```shell
sudo tail -f /var/log/apache2/error.log
```

## Folder Permissions
By default, the `www` folder is owned by root, let's change it to you and `www-data` group.
We are using the `/var/www/html` folder right now, but my config uses the `www` folder
as the main document root.

Use my fix permissions script:
```shell
./fix-permissions.sh # by default will apply to /var/www
```

This should set all the bit mask flags so that any new files created by you or Apache should be
fully accessible by both of you.

It's a good idea to give Apache access to this repo folder as well:
```shell
./fix-permissions.sh $(pwd)
```

Some commands I have later in this README may need the bit masks to be set this way.

## Remove the default page.
Right now the default page is exposing sensitive information and should be removed from production servers.

Even if you remove the default site config, the default page will still be shown if something goes wrong.

You can test this theory by removing the default site and refreshing the page.

The sites enabled folder contains symbolic links to config files that enable each website.
You could just `sudo unlink /etc/apache2/sites-enabled/000-default.conf` or you can use the helper command
`a2dissite` command like so:

```shell
sudo a2dissite 000-default.conf
```
Either way is fine.

Now restart Apache again:
```shell
sudo service apache2 restart
```

Now refresh http://localhost, and you will still see the default page!

There are other deeper configs still pointing to that `/var/www/html` folder as the document root even with the
default config disabled. We could edit core configs, but I prefer to just get rid of the HTML file.

Let's just move it, so you can still read it later if you want, it does have some interesting info.
```shell
mv /var/www/html/index.html ~/ubuntu-default-page.html
```

And then add some generic maintenance message JIC something goes wrong and the default folder is served again.

For now just copy the example:
```shell
cp maintenance.php /var/www/html/index.php
```

## Setting up V-Host configs.

Normally you would create your configs in `/etc/apache2/sites-available/` and then use the `a2ensite` command
to create symlinks to the sites-enabled folder when ready.

But were just going to link my provided config from this repo and restart Apache.

### Adding V-Host config from this repo.

Use my [dynamic localhost](dynamic-vhost.conf) config:

```shell
# do not use relative paths when linking files. That's why I use $(pwd) instead of ./
sudo ln -s $(pwd)/dynamic-vhost.conf /etc/apache2/sites-enabled
```

Verify the contents of the file are there via the new link.
```shell
sudo cat /etc/apache2/sites-enabled/dynamic-vhost.conf
```

### Restart Apache

Enable the new config by restarting. Need to do this every time you change stuff.

```SHELL
sudo service apache2 restart
```

## The Dynamic V-Host config.
The dynamic localhost config will point any domain to a matching folder, ignoring WWW.

- localhost points to `/var/www/localhost/`
- www.localhost points to `/var/www/localhost/`
- animals.localhost points to `/var/www/animals.localhost/`
- some.really.long.domain.gov.edu.au to `/var/www/some.really.long.domain.gov.edu.au/`

Super simple.

## Changing the default port.
You may decide to use a proxy manager in front of your web services and thus
need to change the port for Apache.

```shell
sudo nano /etc/apache2/ports.conf
```
Change the listen ports to something that won't clash with common ports for other systems.

## Configure PHP for production.

I have provided config file with my recommended settings for PHP in production.

It can be automatically included by linking git to the `conf.d` folder.

```shell
sudo ln -s $(pwd)/php-produciton.ini /etc/php/8.3/apache2/conf.d/30-production.ini
```

And double-check the link works:
```shell
sudo cat /etc/php/8.3/apache2/conf.d/30-production.ini
```
