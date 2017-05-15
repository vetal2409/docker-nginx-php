FROM nginx:alpine

MAINTAINER Vitalii Sydorenko <vetal.sydo@gmail.com>

ADD nginx.conf /etc/nginx/

ENV PHP_UPSTREAM=php-fpm

# fix a problem--#397, change application source from dl-cdn.alpinelinux.org to aliyun source.
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/' /etc/apk/repositories

RUN apk update \
    && apk upgrade \
    && apk add --no-cache bash \
    && adduser -D -H -u 1000 -s /bin/bash www-data \
    && rm /etc/nginx/conf.d/default.conf 

EXPOSE 80 443

# Start!
COPY ./start /usr/local/bin/
RUN chmod +x /usr/local/bin/start
CMD ["start"]
