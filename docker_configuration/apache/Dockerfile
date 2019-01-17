FROM scratch
#################################### install Ubuntu 16.04 from archive #################################################
ADD ubuntu/ubuntu-xenial-core-cloudimg-amd64-root.tar.gz /

# a few minor docker-specific tweaks
# see https://github.com/docker/docker/blob/9a9fc01af8fb5d98b8eec0740716226fadb3735c/contrib/mkimage/debootstrap
RUN set -xe \
	\
# https://github.com/docker/docker/blob/9a9fc01af8fb5d98b8eec0740716226fadb3735c/contrib/mkimage/debootstrap#L40-L48
	&& echo '#!/bin/sh' > /usr/sbin/policy-rc.d \
	&& echo 'exit 101' >> /usr/sbin/policy-rc.d \
	&& chmod +x /usr/sbin/policy-rc.d \
	\
# https://github.com/docker/docker/blob/9a9fc01af8fb5d98b8eec0740716226fadb3735c/contrib/mkimage/debootstrap#L54-L56
	&& dpkg-divert --local --rename --add /sbin/initctl \
	&& cp -a /usr/sbin/policy-rc.d /sbin/initctl \
	&& sed -i 's/^exit.*/exit 0/' /sbin/initctl \
	\
# https://github.com/docker/docker/blob/9a9fc01af8fb5d98b8eec0740716226fadb3735c/contrib/mkimage/debootstrap#L71-L78
	&& echo 'force-unsafe-io' > /etc/dpkg/dpkg.cfg.d/docker-apt-speedup \
	\
# https://github.com/docker/docker/blob/9a9fc01af8fb5d98b8eec0740716226fadb3735c/contrib/mkimage/debootstrap#L85-L105
	&& echo 'DPkg::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' > /etc/apt/apt.conf.d/docker-clean \
	&& echo 'APT::Update::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' >> /etc/apt/apt.conf.d/docker-clean \
	&& echo 'Dir::Cache::pkgcache ""; Dir::Cache::srcpkgcache "";' >> /etc/apt/apt.conf.d/docker-clean \
	\
# https://github.com/docker/docker/blob/9a9fc01af8fb5d98b8eec0740716226fadb3735c/contrib/mkimage/debootstrap#L109-L115
	&& echo 'Acquire::Languages "none";' > /etc/apt/apt.conf.d/docker-no-languages \
	\
# https://github.com/docker/docker/blob/9a9fc01af8fb5d98b8eec0740716226fadb3735c/contrib/mkimage/debootstrap#L118-L130
	&& echo 'Acquire::GzipIndexes "true"; Acquire::CompressionTypes::Order:: "gz";' > /etc/apt/apt.conf.d/docker-gzip-indexes \
	\
# https://github.com/docker/docker/blob/9a9fc01af8fb5d98b8eec0740716226fadb3735c/contrib/mkimage/debootstrap#L134-L151
	&& echo 'Apt::AutoRemove::SuggestsImportant "false";' > /etc/apt/apt.conf.d/docker-autoremove-suggests

# delete all the apt list files since they're big and get stale quickly
RUN rm -rf /var/lib/apt/lists/*
# this forces "apt-get update" in dependent images, which is also good
# (see also https://bugs.launchpad.net/cloud-images/+bug/1699913)

# enable the universe
RUN sed -i 's/^#\s*\(deb.*universe\)$/\1/g' /etc/apt/sources.list

# make systemd-detect-virt return "docker"
# See: https://github.com/systemd/systemd/blob/aa0c34279ee40bce2f9681b496922dedbadfca19/src/basic/virt.c#L434
RUN mkdir -p /run/systemd && echo 'docker' > /run/systemd/container

# overwrite this with 'CMD []' in a dependent Dockerfile
CMD ["/bin/bash"]
########################################################################################################################

############################################ install apache 2 ##########################################################
RUN apt-get update && \
    apt-get install -y curl && \
    apt-get install -y nano && \
    apt-get install -y apache2

RUN apt-get install net-tools
# mod_rewrite
RUN a2enmod rewrite

#enable autostart for apache2
RUN /lib/systemd/systemd-sysv-install enable apache2

#install Imagick to correctly show images
RUN apt-get install -y php-imagick
########################################################################################################################

############################################### xdebug settings ########################################################
COPY xdebug/xdebug.ini /root/xdebug.ini
########################################################################################################################

#################################### change default virtual host #######################################################
#backup original default configuration
RUN cd etc/apache2/sites-available/ cp 000-default.conf 000-default.conf_backup

#copy new host configuration instead of the default one
COPY virtual_host/default.conf etc/apache2/sites-available/000-default.conf

# Apache port configuration
# replace every occurance of 80 with 8080, if this approach is not suitable, you can manually change the port

# apache will be running under 8080 port, instead of the default 80
RUN cd etc/apache2 && sed -i -e 's/80/8080/g' ports.conf
# all available sites will be running under 8080 port, instead of the default 80
RUN cd etc/apache2 && sed -i -e 's/80/8080/g' sites-available/*

########################################################################################################################

########################################### install php 5.6 ############################################################
RUN apt-get update && \
    apt-get install -y language-pack-en-base && \
    export LC_ALL=en_US.UTF-8 && \
    export LANG=en_US.UTF-8 && \
    apt-get install -y software-properties-common && \
    apt-get install -y python-software-properties

# add repository to get php 5.6
RUN LC_ALL=en_US.UTF-8 add-apt-repository -y ppa:ondrej/php
RUN apt-get update
RUN apt-get install -y php5.6 && \
    apt-get install -y php5.6-mysql && \
    apt-get install -y php5.6-xml && \
    apt-get install -y php5.6-soap && \
    apt-get install -y php5.6-intl && \
    apt-get install -y php5.6-mbstring && \
    apt-get install -y php5.6-cli && \
    apt-get install -y php5.6-gd && \
    apt-get install -y php5.6-apcu && \
    apt-get install -y php5.6-memcached && \
    apt-get install -y php5.6-xdebug && \
    apt-get install -y php5.6-opcache && \
    apt-get install -y php5.6-curl && \
    apt-get install -y php5.6-mcrypt && \
    apt-get install -y sendmail
########################################################################################################################

########################################### install php 7.0 ############################################################
RUN apt-get install -y php7.0 && \
    apt-get install -y php7.0-mysql && \
    apt-get install -y php7.0-xml && \
    apt-get install -y php7.0-soap && \
    apt-get install -y php7.0-intl && \
    apt-get install -y php7.0-mbstring && \
    apt-get install -y php7.0-cli && \
    apt-get install -y php7.0-gd && \
    apt-get install -y php7.0-apcu &&\
    apt-get install -y php7.0-memcached &&\
    apt-get install -y php7.0-xdebug &&\
    apt-get install -y php7.0-curl && \
    apt-get install -y php7.0-mcrypt && \
    apt-get install -y php7.0-opcache
########################################################################################################################

########################################### install php 7.2 ############################################################
RUN apt-get install -y php7.2 && \
    apt-get install -y php7.2-mysql && \
    apt-get install -y php7.2-xml && \
    apt-get install -y php7.2-soap && \
    apt-get install -y php7.2-intl && \
    apt-get install -y php7.2-mbstring && \
    apt-get install -y php7.2-cli && \
    apt-get install -y php7.2-gd && \
    apt-get install -y php7.2-curl
########################################### install deprecated 'mcrypt' on PHP 7.2 #####################################
# Because of the end of the 'mcrypt' extension's development, the extension was also removed from PHP 7.2 and moved to
# an unofficial PECL repository. For PHP 7.2+, PHP instead uses 'libsodium' as a cryptography library.

# To install 'mcrypt' extension on PHP 7.2 run these commands inside docker container:
# apt-get install -y php-dev libmcrypt-dev php-pear
# pecl channel-update pecl.php.net
# pecl install mcrypt-1.0.1  - here, when you are shown the prompt with context "libmcrypt prefix? [autodetect] :", just hit 'Enter'

# After success installing 'mcrypt', you should add 'mcrypt.so' extension to php.ini
# The output will look like this:

#// Build process completed successfully
#// Installing '/usr/lib/php/20170718/mcrypt.so'   ---->   this is our path to mcrypt extension lib
#// install ok: channel://pecl.php.net/mcrypt-1.0.1
#// configuration option "php_ini" is not set to php.ini location
#// You should add "extension=mcrypt.so" to php.ini

# Grab installing path and add to cli and apache2 php.ini configuration:

# bash -c "echo extension=/usr/lib/php/20170718/mcrypt.so > /etc/php/7.2/cli/conf.d/mcrypt.ini"
# bash -c "echo extension=/usr/lib/php/20170718/mcrypt.so > /etc/php/7.2/apache2/conf.d/mcrypt.ini"
# service apache2 restart

########################################################################################################################

################################################## Composer, Modman ####################################################
#install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
#install modman
RUN curl -SL https://raw.githubusercontent.com/colinmollenhour/modman/master/modman -o modman \
    && chmod +x ./modman \
    && mv ./modman /usr/local/bin/
########################################################################################################################
ENTRYPOINT service apache2 start && /bin/bash
EXPOSE 8080