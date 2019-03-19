# docker-wp-lamp

based on [dgraziotin/osx-docker-lamp](https://github.com/dgraziotin/osx-docker-lamp)

## LAMP
	Ubuntu 16.04
	Apache2
	PHP7.0
	MySQL
	- user: admin
	- pass: pass

## features
	WP-CLI
	PHPMyAdmin
	- localhost/phpmyadmin
	Self Signed SSL

## instructions

### file structure
	my-project
	|- app (web files)
	|- mysql
	
### create image
	docker build -t wp-lamp:latest .

### run docker
	cd my-project (ensure it's setup like the file structure is)
	docker run -itp 80:80 -p 443:443 -v ${PWD}/app:/var/www/html -v ${PWD}/mysql:/var/lib/mysql wp-lamp:latest
