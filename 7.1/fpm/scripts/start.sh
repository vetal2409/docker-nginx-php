#!/usr/bin/env bash

echo "Begin executing start script";


if [ -n "$PHP_CLI_MEMORY_LIMIT" ]; then
    echo "Set cli memory limit: $PHP_CLI_MEMORY_LIMIT";
	sed -i "s/memory_limit = .*/memory_limit = $PHP_CLI_MEMORY_LIMIT/" /etc/php/7.1/cli/php.ini
fi;
if [ -n "$PHP_FPM_MEMORY_LIMIT" ]; then
    echo "Set fpm memory limit: $PHP_FPM_MEMORY_LIMIT";
    sed -i "s/memory_limit = .*/memory_limit = $PHP_FPM_MEMORY_LIMIT/" /etc/php/7.1/fpm/php.ini
fi;

# Retrieve host ip
if [ -z "$HOST_IP" ]; then
	# Allows to set HOST_IP by env variable because could be different from the one which come from ip route command
	HOST_IP=$(/sbin/ip route|awk '/default/ { print $3 }')
fi;

# Enable XDebug auto start
if [ "$PHP_XDEBUG_REMOTE_AUTOSTART" = "1" ]; then
    sed -i "s/xdebug.remote_autostart=0/xdebug.remote_autostart=1/" /etc/php/7.1/mods-available/xdebug.ini
    sed -i "s/xdebug.remote_connect_back=.*/xdebug.remote_host=$HOST_IP/" /etc/php/7.1/mods-available/xdebug.ini
    echo "xDebug remote auto-start enabled changes. remote_host=$HOST_IP  and remote_autostart=1";
fi;

# Run cron
crontab /etc/cron.d/default
cron


if [ -d "/var/scripts/" ]; then
    # make scripts executable incase they aren't
    chmod -Rf 750 /var/scripts/*
    # run scripts in number order
    for i in `ls /var/scripts/`; do /var/scripts/$i ; done
else
    echo "Can't find script directory"
fi


echo "End executing start script";
exec "/usr/bin/supervisord"
