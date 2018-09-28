# docker-wp-lamp

based on [dgraziotin/osx-docker-lamp](https://github.com/dgraziotin/osx-docker-lamp)

## LAMP
	Ubuntu 16.04
	Apache2
	PHP7.0
	MySQL

## features
	WP-CLI
	PHPMyAdmin

## instructions
	docker build -t docker-wp-lamp:latest <path-to-repo>
	docker run -itp 80:80 -v ${PWD}/app:/var/www/html -v ${PWD}/mysql:/var/lib/mysql docker-wp-lamp:latest
