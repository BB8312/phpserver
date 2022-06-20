#!/bin/sh

AdminVer="5.2.0"
InfoVer="2.0.3"
TLVer="1.9.20"

mkdir -p /usr/share/webapps/ && cd /usr/share/webapps/ && wget https://files.phpmyadmin.net/phpMyAdmin/${AdminVer}/phpMyAdmin-${AdminVer}-all-languages.tar.gz > /dev/null 2>&1 && tar -xzvf phpMyAdmin-${AdminVer}-all-languages.tar.gz > /dev/null 2>&1 && mv phpMyAdmin-${AdminVer}-all-languages phpmyadmin
chmod -R 777 /usr/share/webapps/ && ln -s /usr/share/webapps/phpmyadmin/ /var/www/localhost/htdocs/phpmyadmin && wget https://master.dl.sourceforge.net/project/linfo/Linfo%20Stable%20Releases/linfo-${InfoVer}.tar.gz > /dev/null 2>&1 && tar -xzvf linfo-${InfoVer}.tar.gz > /dev/null 2>&1 && mv linfo-${InfoVer} linfo && mv /usr/share/webapps/linfo/sample.config.inc.php /usr/share/webapps/linfo/config.inc.php && ln -s /usr/share/webapps/linfo/ /var/www/localhost/htdocs/linfo
wget https://deac-ams.dl.sourceforge.net/project/testlink/TestLink%201.9/TestLink%20${TLVer}/testlink-${TLVer}.tar.gz > /dev/null 2>&1 && tar -xzvf testlink-${TLVer}.tar.gz > /dev/null 2>&1 && mv testlink-${TLVer} testlink && ln -s /usr/share/webapps/testlink/ /var/www/localhost/htdocs/testlink
mkdir /usr/share/webapps/data/testlink
mkdir /usr/share/webapps/data/testlink/logs
mkdir /usr/share/webapps/data/testlink/upload_area
mkdir /usr/share/webapps/data/testlink/templates_c
rm -R /usr/share/webapps/testlink/gui/templates_c && ln -s /usr/share/webapps/data/testlink/templates_c /usr/share/webapps/testlink/gui/templates_c
chmod -R 777 /usr/share/webapps/data/
mkdir /var/testlink/ && ln -s /usr/share/webapps/data/testlink/logs /var/testlink/logs && ln -s /usr/share/webapps/data/testlink/upload_area /var/testlink/upload_area && ln -s /usr/share/webapps/data/testlink/config_db.inc.php /usr/share/webapps/testlink/config_db.inc.php
if [ ! -f /usr/share/webapps/data/bfs ]; then openssl rand -base64 24 > /usr/share/webapps/data/bfs; fi && read bfs </usr/share/webapps/data/bfs && echo -e "<?php\n\$cfg['blowfish_secret'] = '$bfs';" > /usr/share/webapps/phpmyadmin/config.inc.php

# Start Apache
httpd

# Check MySQL data directory, install the db if needed
if [ ! -f /var/lib/mysql/ibdata1 ]; then
    mariadb-install-db --user=mysql --ldata=/var/lib/mysql > /dev/nul
fi;

tfile=`mktemp`
if [ ! -f "$tfile" ]; then
    return 1
fi

if [ ! -f /var/lib/mysql/testlink/users.ibd ]; then
cat << EOF > $tfile
    USE mysql;
    DELETE FROM user;
    FLUSH PRIVILEGES;
    GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY "$HOSTNAME" WITH GRANT OPTION;
    GRANT ALL ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
    UPDATE user SET password=PASSWORD("") WHERE user='root' AND host='localhost';
    FLUSH PRIVILEGES;
EOF
fi

/usr/bin/mysqld --user=root --bootstrap --verbose=0 < $tfile
rm -f $tfile

# Start MySQL
exec /usr/bin/mysqld --user=root --bind-address=0.0.0.0
