FROM alpine:edge
MAINTAINER Jeronica


ENV PYTHON_VERSION=2.7.10-r1
ENV PY_PIP_VERSION=6.1.1-r0
ENV SUPERVISOR_VERSION=3.2.0

RUN apk update \
    && apk add bash nginx ca-certificates \
    php-fpm php-json php-zlib php-xml php-pdo php-phar php-openssl \
    php-pdo_mysql php-mysqli \
    php-gd php-iconv php-mcrypt \
    nano php-curl
RUN apk add -u python py-pip php-ctype rsyslog php-bcmath
RUN pip install supervisor
RUN apk add -u musl
RUN rm -rf /var/cache/apk/*

ADD nginx.conf /etc/nginx/
ADD php.conf /etc/php/php-fpm.conf

# tweak nginx config
RUN sed -i -e"s/worker_processes  1/worker_processes 5/" /etc/nginx/nginx.conf && \
sed -i -e"s/keepalive_timeout\s*65/keepalive_timeout 2/" /etc/nginx/nginx.conf && \
sed -i -e"s/keepalive_timeout 2/keepalive_timeout 2;\n\tclient_max_body_size 100m/" /etc/nginx/nginx.conf

# nginx site conf
RUN rm -Rf /etc/nginx/conf.d/* && \
rm -Rf /etc/nginx/sites-available/default && \
mkdir -p /etc/nginx/ssl/
ADD ./nginx-site.conf /etc/nginx/sites-available/default.conf

# Supervisor Config
ADD ./supervisord.conf /etc/supervisord.conf

# Start Supervisord
ADD ./start.sh /start.sh
RUN chmod 755 /start.sh

# Setup Volume
VOLUME ["/data/html"]

# add test PHP file
ADD ./index.php /data/html/index.php

# Expose Ports
EXPOSE 443
EXPOSE 80

CMD ["/bin/bash", "/start.sh"]
