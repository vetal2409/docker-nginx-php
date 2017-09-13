#!/usr/bin/env bash

if `ls /etc/php/7.0/fpm/conf.d | grep -q xdebug`
then
    phpdismod xdebug
    service php7.0-fpm reload
    echo "xdebug disabled"
else
    phpenmod xdebug
    service php7.0-fpm reload
    echo "xdebug enabled"
fi
