FROM ubuntu:16.04

MAINTAINER Vitalii Sydorenko <vetal.sydo@gmail.com>

ENV DEBIAN_FRONTEND noninteractive
ENV PHP_XDEBUG_REMOTE_AUTOSTART 1
ENV PHP_CLI_MEMORY_LIMIT 512M
ENV PHP_FPM_MEMORY_LIMIT 512M


# install dependency
RUN apt-get update \
    && apt-get install -y software-properties-common python-software-properties \
    && apt-get install -y language-pack-en-base
RUN LC_ALL=en_US.UTF-8 add-apt-repository -y ppa:ondrej/php

# install packages
RUN apt-get update \
    && apt-get -y --no-install-recommends install \
    nano \
    tree \
    curl \
    apt-transport-https \
    wget \
    git \
    supervisor \
    nginx \
    acl \
    iproute2 \
    wkhtmltopdf \
    mongodb \
    php7.0-fpm php7.0-cli php7.0-common php7.0-curl php7.0-gd php7.0-intl php7.0-json php7.0-mbstring php7.0-mcrypt \
    php7.0-mysql php7.0-opcache php7.0-pgsql php7.0-soap php7.0-sqlite3 php7.0-xml php7.0-xmlrpc php7.0-xsl php7.0-zip \
    php7.0-mongodb php7.0-redis php7.0-imap php7.0-memcached php7.0-xdebug php7.0-exif php7.0-readline php7.0-bcmath

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --filename=composer --install-dir=/usr/local/bin

# clear apt cache and remove unnecessary packages
RUN apt-get autoclean && apt-get -y autoremove

RUN addgroup --system nginx && \
    adduser --system --home /var/cache/nginx --shell /sbin/nologin --disabled-password --ingroup nginx nginx
## NGINX configuration
# redo directory structure
RUN mkdir -p /etc/nginx/sites \
    && mv /etc/nginx/sites-available/default /etc/nginx/sites/default.nginx \
    && rm -r /etc/nginx/sites-available /etc/nginx/sites-enabled
# bakup configurations
RUN cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
# copy new configurations
COPY config/nginx/nginx.conf /etc/nginx/nginx.conf
# create php virtual host
RUN mkdir -p /opt/app && echo "<?php phpinfo();" >> /opt/app/index.php
COPY config/nginx/sites/php.nginx /etc/nginx/sites/php.nginx


## PHP configuration
# bakup configurations
RUN cp /etc/php/7.0/fpm/php-fpm.conf /etc/php/7.0/fpm/php-fpm.conf.bak \
    && cp /etc/php/7.0/fpm/pool.d/www.conf /etc/php/7.0/fpm/pool.d/www.conf.bak \
    && cp /etc/php/7.0/fpm/php.ini /etc/php/7.0/fpm/php.ini.bak \
    && cp /etc/php/7.0/cli/php.ini /etc/php/7.0/cli/php.ini.bak
# copy new configurations
COPY config/php/fpm/php-fpm.conf /etc/php/7.0/fpm/php-fpm.conf
COPY config/php/fpm/pool.d/www.conf /etc/php/7.0/fpm/pool.d/www.conf
COPY config/php/fpm/php.ini /etc/php/7.0/fpm/php.ini
COPY config/php/cli/php.ini /etc/php/7.0/cli/php.ini
COPY config/php/mods-available/xdebug.ini /etc/php/7.0/mods-available/xdebug.ini
# php7.0-fpm will not start if this directory does not exist
RUN mkdir /run/php
# mods configuration
RUN phpdismod xdebug
RUN echo "export PHP_IDE_CONFIG=\"serverName=server\"" >> ~/.bashrc

## Supervisor configuration
# copy config file for Supervisor
COPY config/supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

WORKDIR /opt/app

# NGINX ports
EXPOSE 80

# Add crontab default file, Give execution rights on the cron job, Create the log file to be able to run tail
RUN touch /etc/cron.d/default \
    && chmod 0644 /etc/cron.d/default \
    && mkdir -p /var/log/cron/ && touch /var/log/cron/default.log

COPY scripts /var/scripts

RUN mv /var/scripts/wait-for-it.sh /usr/bin/waitforit

RUN mv /var/scripts/xdebug.sh /usr/local/bin/xdebug
RUN chmod +x /usr/local/bin/xdebug

RUN mv /var/scripts/start.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start.sh
CMD ["start.sh"]
