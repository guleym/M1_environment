#!/usr/bin/env bash

a2dismod php7.2 && a2enmod php5.6 && service apache2 stop && service apache2 start