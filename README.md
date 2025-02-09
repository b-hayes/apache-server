# apache-server

Notes on running an apache server in Ubuntu.

# Installation.

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

Create a folder for your all your websites and create a link from apaches default folder.

You need to do this because apache needs permissions on all the parent folders
that lead up to the path you want as doucment root.

Its not safe to just give that power to all your home folder paths.
