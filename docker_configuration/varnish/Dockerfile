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

########################################## install Varnish 4.1.1 #######################################################


###################### first option ######################
# install from the official varnish-cache.org repos
###########################################################
# RUN apt-get update && \
#    apt-get install -y curl gnupg apt-transport-https

# RUN curl -L https://packagecloud.io/varnishcache/varnish41/gpgkey | apt-key add -

# COPY conf/varnishcache_varnish41.list /etc/apt/sources.list.d/varnishcache_varnish41.list

# RUN apt-get update && \
#     apt-get install -y varnish
###########################################################


###################### second option ######################
# install from .deb package, second option (if the first option will not be available)
###########################################################
RUN apt-get update && \
    apt-get install -y curl gnupg apt-transport-https && \
    apt-get install net-tools

COPY varnish_deb_package/varnish_4.1.10-1_xenial_amd64.deb /tmp/varnish_deb_package/varnish_4.1.10-1_xenial_amd64.deb

# install dependencies
RUN apt-get update && \
    apt-get install -y libc6 && \
    apt-get install -y libedit2 && \
    apt-get install -y libjemalloc1 && \
    apt-get install -y libncurses5 && \
    apt-get install -y libpcre3 && \
    apt-get install -y libtinfo5 && \
    apt-get install -y init-system-helpers && \
    apt-get install -y adduser && \
    apt-get install -y gcc && \
    apt-get install -y libc6-dev

# install deb package and clean
RUN cd /tmp/varnish_deb_package/ && \
    dpkg -i varnish_4.1.10-1_xenial_amd64.deb && \
    rm -rf varnish_deb_package/
###########################################################

# added the possibility to change Varnish configuration
RUN cp /etc/varnish/default.vcl /etc/varnish/default.vcl.backup
COPY conf/default.vcl /etc/varnish/default.vcl

RUN cp /etc/default/varnish /etc/default/varnish.backup
COPY conf/varnish /etc/default/varnish

RUN cp /lib/systemd/system/varnish.service /lib/systemd/system/varnish.service_backup
COPY conf/varnish.service  /lib/systemd/system/varnish.service

########################################################################################################################
ENTRYPOINT service varnish start && /bin/bash
EXPOSE 80
EXPOSE 6082