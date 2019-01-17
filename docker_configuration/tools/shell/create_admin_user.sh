#!/usr/bin/env bash

cd /tmp
cp n98-magerun.phar /var/www/html/
cd /var/www/html/
php n98-magerun.phar admin:user:create nico email@gmail.com 123123q firstname lastname