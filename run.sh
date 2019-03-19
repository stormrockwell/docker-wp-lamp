#!/bin/bash

VOLUME_HOME="/var/lib/mysql"

sed -ri -e "s/^upload_max_filesize.*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" \
    -e "s/^post_max_size.*/post_max_size = ${PHP_POST_MAX_SIZE}/" /etc/php/7.0/apache2/php.ini

sed -i "s/export APACHE_RUN_GROUP=www-data/export APACHE_RUN_GROUP=staff/" /etc/apache2/envvars

if [ -n "$APACHE_ROOT" ];then
    rm -f /var/www/html && ln -s "/app/${APACHE_ROOT}" /var/www/html
fi

sed -i -e "s/cfg\['blowfish_secret'\] = ''/cfg['blowfish_secret'] = '`date | md5sum`'/" /var/www/phpmyadmin/config.inc.php

# If there's no mysql folder, create DB and user
if [[ ! -d $VOLUME_HOME/mysql ]]; then
    echo "=> An empty or uninitialized MySQL volume is detected in $VOLUME_HOME"
    echo "=> Installing MySQL ..."
    mysqld --initialize-insecure --explicit_defaults_for_timestamp=1 > /dev/null 2>&1
    echo "=> Done!"
else
    echo "=> Using an existing volume of MySQL"
fi

if [ -n "$VAGRANT_OSX_MODE" ];then
    usermod -u $DOCKER_USER_ID www-data
    groupmod -g $(($DOCKER_USER_GID + 10000)) $(getent group $DOCKER_USER_GID | cut -d: -f1)
    groupmod -g ${DOCKER_USER_GID} staff
    chmod -R 770 /var/lib/mysql
    chmod -R 770 /var/run/mysqld
    chown -R www-data:staff /var/lib/mysql
    chown -R www-data:staff /var/run/mysqld
else
    # Tweaks to give Apache/PHP write permissions to the app
    chown -R www-data:staff /var/www
    chown -R www-data:staff /app
    chown -R www-data:staff /var/lib/mysql
    chown -R www-data:staff /var/run/mysqld
    chmod -R 770 /var/lib/mysql
    chmod -R 770 /var/run/mysqld
fi

sed -i "s/bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/my.cnf
sed -i "s/user.*/user = www-data/" /etc/mysql/my.cnf

# Set alias for --allow-root so WP-CLI wont bug you
echo "alias wp='/usr/local/bin/wp --allow-root'" > ~/.bashrc

service apache2 start
service mysql start

# Create admin MySQL user
mysql -uroot -e "CREATE USER IF NOT EXISTS 'admin'@'%' IDENTIFIED BY 'pass'"
mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION"
mysql -uroot -e "FLUSH PRIVILEGES"

/bin/bash
