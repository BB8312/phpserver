FROM alpine:3.15.4
# Set timezone here
ENV TIMEZONE Europe/Minsk
RUN apk update && apk upgrade
RUN apk add mariadb mariadb-client apache2 apache2-utils curl wget tzdata php7-apache2 php7-cli php7-phar php7-zlib php7-zip php7-bz2 php7-ctype php7-curl php7-pdo_mysql php7-mysqli php7-json php7-mcrypt php7-xml php7-dom php7-iconv php7-xdebug php7-session php7-intl php7-gd php7-mbstring php7-apcu php7-opcache php7-tokenizer openssl

# A Dependency Manager for PHP
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

# Configure timezone, mariadb, httpd, php
RUN cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && echo "${TIMEZONE}" > /etc/timezone && \
    mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld /var/lib/mysql && \
    mkdir -p /run/apache2 && chown -R apache:apache /run/apache2 && chown -R apache:apache /var/www/localhost/htdocs/ && \
    sed -i 's#\#LoadModule rewrite_module modules\/mod_rewrite.so#LoadModule rewrite_module modules\/mod_rewrite.so#' /etc/apache2/httpd.conf && \
    sed -i 's#ServerName www.example.com:80#\nServerName localhost:80#' /etc/apache2/httpd.conf && \
    sed -i 's/skip-networking/\#skip-networking/i' /etc/my.cnf.d/mariadb-server.cnf && \
    sed -i '/mariadb\]/a log_error = \/var\/lib\/mysql\/error.log' /etc/my.cnf.d/mariadb-server.cnf && \
    sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/my.cnf.d/mariadb-server.cnf && \
    sed -i '/mariadb\]/a skip-external-locking' /etc/my.cnf.d/mariadb-server.cnf && \
    sed -i '/mariadb\]/a explicit_defaults_for_timestamp = true' /etc/my.cnf.d/mariadb-server.cnf && \
    sed -i '/mariadb\]/a general_log = ON' /etc/my.cnf.d/mariadb-server.cnf && \
    sed -i '/mariadb\]/a general_log_file = \/var\/lib\/mysql\/query.log' /etc/my.cnf.d/mariadb-server.cnf

RUN sed -i 's#upload_max_filesize = 2M#upload_max_filesize = 100M#' /etc/php7/php.ini && \
    sed -i 's#post_max_size = 8M#post_max_size = 100M#' /etc/php7/php.ini && \
    sed -i 's#session.cookie_httponly =#session.cookie_httponly = true#' /etc/php7/php.ini

COPY ep.sh /ep.sh

RUN chmod u+x /ep.sh

WORKDIR /var/www/localhost/htdocs/

EXPOSE 80

ENTRYPOINT ["/ep.sh"]
