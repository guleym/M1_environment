FROM nginx:1.13

RUN touch /var/run/nginx.pid

RUN apt-get update && apt-get install -y openssl && apt-get install -y net-tools
RUN mkdir /etc/nginx/certs \
  && echo -e "\n\n\n\n\n\n\n" | openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/certs/nginx.key -out /etc/nginx/certs/nginx.crt

COPY ./conf/nginx.conf /etc/nginx/
COPY ./conf/default.conf /etc/nginx/conf.d/

VOLUME /var/www
WORKDIR /var/www/html

EXPOSE 8000

ENTRYPOINT service nginx start && /bin/bash