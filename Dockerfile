FROM php:8.3-apache

RUN a2enmod rewrite

# Install Docker client (remove if none of your apps need this)
RUN apt-get update && apt-get install -y \
    docker.io \
    && docker --version

RUN usermod -aG docker www-data

sudo chmod  \
    757 /var/run/docker.sock