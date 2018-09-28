FROM phusion/baseimage:latest

# based on dgraziotin/osx-docker-lamp

ENV DOCKER_USER_ID 501 
ENV DOCKER_USER_GID 20

ENV BOOT2DOCKER_ID 1000
ENV BOOT2DOCKER_GID 50

# Tweaks to give Apache/PHP write permissions to the app
RUN usermod -u ${BOOT2DOCKER_ID} www-data && \
    usermod -G staff www-data && \
    useradd -r mysql && \
    usermod -G staff mysql

RUN groupmod -g $(($BOOT2DOCKER_GID + 10000)) $(getent group $BOOT2DOCKER_GID | cut -d: -f1)
RUN groupmod -g ${BOOT2DOCKER_GID} staff

# Install packages
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
	apt-get -y install wget git apache2 pwgen zip unzip \
	php7.0 libapache2-mod-php7.0 php7.0-cli php7.0-common \
	php7.0-mbstring php7.0-gd php7.0-intl php7.0-xml php7.0-mysql php7.0-mcrypt \
	php7.0-zip && \
	echo "ServerName localhost" >> /etc/apache2/apache2.conf

RUN apt-get update && apt-get install -y mysql-server

# Needed for phpMyAdmin
run phpenmod mcrypt

# Add scripts
ADD run.sh /run.sh
RUN chmod 755 /*.sh

# Remove pre-installed database
RUN rm -rf /var/lib/mysql

# Add MySQL utils
ADD create_mysql_users.sh /create_mysql_users.sh
RUN chmod 755 /*.sh

# Add PHPMyAdmin
RUN wget -O /tmp/phpmyadmin.tar.gz https://files.phpmyadmin.net/phpMyAdmin/4.6.0/phpMyAdmin-4.6.0-all-languages.tar.gz
RUN tar xfvz /tmp/phpmyadmin.tar.gz -C /var/www
RUN ln -s /var/www/phpMyAdmin-4.6.0-all-languages /var/www/phpmyadmin
RUN mv /var/www/phpmyadmin/config.sample.inc.php /var/www/phpmyadmin/config.inc.php

# Add WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod +x wp-cli.phar \
	&& mv wp-cli.phar /usr/local/bin/wp \
	&& echo 'Installing WP-CLI'

# config to enable .htaccess
ADD apache_default /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

# Configure /app folder with sample app
RUN mkdir -p /app && rm -fr /var/www/html && ln -s /app /var/www/html
ADD app/ /app

#Environment variables to configure php
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M

# Add volumes for the app and MySql
VOLUME  ["/etc/mysql", "/var/lib/mysql", "/app" ]

EXPOSE 80 3306
CMD ["/run.sh"]