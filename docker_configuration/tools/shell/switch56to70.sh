#!/usr/bin/env bash

a2dismod php5.6 && a2enmod php7.0 && service apache2 stop && service apache2 start