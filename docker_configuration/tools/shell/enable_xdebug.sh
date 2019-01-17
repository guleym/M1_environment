#!/usr/bin/env bash

cat /root/xdebug.ini >> /etc/php/5.6/mods-available/xdebug.ini
cat /root/xdebug.ini >> /etc/php/7.0/mods-available/xdebug.ini
cat /root/xdebug.ini >> /etc/php/7.2/mods-available/xdebug.ini

service apache2 restart