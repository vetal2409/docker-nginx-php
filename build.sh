#!/usr/bin/env bash

docker build -t vetal2409/nginx-php:7.1 ./7.1
docker push vetal2409/nginx-php:7.1


docker build -t vetal2409/nginx-php:7.0 ./7.0
docker push vetal2409/nginx-php:7.0
