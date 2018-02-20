#!/usr/bin/env bash

echo "Begin executing start script";

if [ -d "/var/scripts/before" ]; then
    echo "Run 'before' scripts";
    # make scripts executable in case they aren't
    chmod -Rf 750 /var/scripts/before/*
    # run scripts in number order
    for i in `ls /var/scripts/before/`;do
        echo "$i";
        /var/scripts/before/$i ;
    done
else
    echo "Can't find 'before' script directory"
fi


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

if [ ! -z "$PUID" ]; then
    if [ -z "$PGID" ]; then
        PGID=${PUID}
    fi
    deluser --remove-home nginx
    addgroup --system --gid ${PUID} nginx
    adduser --system --home /var/cache/nginx --shell /sbin/nologin --disabled-password --uid ${PUID} --ingroup nginx nginx
fi

if [ ! -z "$ACL_DIRS" ]; then
    mkdir -p $ACL_DIRS
    WEB_SERVER_USER=nginx
    echo "Web server user: ${WEB_SERVER_USER}"
    setfacl -dR -m u:"$WEB_SERVER_USER":rwX -m u:$(whoami):rwX $ACL_DIRS
    echo "setfacl -dR -m u:\"$WEB_SERVER_USER\":rwX -m u:$(whoami):rwX $ACL_DIRS"
    setfacl -R -m u:"$WEB_SERVER_USER":rwX -m u:$(whoami):rwX $ACL_DIRS
    echo "setfacl -R -m u:\"$WEB_SERVER_USER\":rwX -m u:$(whoami):rwX $ACL_DIRS"
fi

# Run cron
crontab /etc/cron.d/default
cron


if [ -d "/var/scripts/after" ]; then
    echo "Run 'after' scripts";
    # make scripts executable in case they aren't
    chmod -Rf 750 /var/scripts/after/*
    sleep 1;
    # run scripts in number order
    for i in `ls /var/scripts/after/`;do
        echo "$i";
        /var/scripts/after/$i ;
    done
else
    echo "Can't find 'after' script directory"
fi


echo "End executing start script";
exec "/usr/bin/supervisord"
