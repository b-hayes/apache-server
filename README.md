# apache-server

The docker version doesnt work properly.

You can exec into this container and then run docker PS to view other containers, 
but apache phph will never have permissions to access the socket even
with all the permissions configured.

I cant resolve this so I need to use native apache to have a php app that can
see all the running containers and help manage them in a dashboard.