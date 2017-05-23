FROM php:7.1-fpm-alpine

ENV IMAGICK_VERSION 3.4.3

RUN set -x \
	&& deluser www-data \
	&& apk add --no-cache git \	
	
	&& apk add --no-cache --virtual .imagick-build-dependencies autoconf g++ gcc imagemagick-dev libtool make tar \
	&& apk add --virtual .imagick-runtime-dependencies \
  imagemagick \
  	&& git clone -o ${IMAGICK_VERSION} --depth 1 https://github.com/mkoppanen/imagick.git /tmp/imagick \
	&& cd /tmp/imagick \
	&& phpize \
	&& ./configure \
	&& make \
	&& make install \
	&& echo "extension=imagick.so" > /usr/local/etc/php/conf.d/ext-imagick.ini \
	&& apk del .imagick-build-dependencies \
	
	&& apk add --update libjpeg-turbo-dev libpng-dev freetype-dev\
	&& docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
	&& docker-php-ext-install opcache gd mysqli pdo pdo_mysql \
	&& php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/bin --filename=composer \
    && php -r "unlink('composer-setup.php');" \
    && composer require "phpunit/phpunit" --prefer-source --no-interaction \
    && ln -s /tmp/vendor/bin/phpunit /usr/local/bin/phpunit \
	&& apk del libtool autoconf gcc g++ make \
	&& addgroup -g 1000 -S www-data \
	&& adduser -u 1000 -D -S -G www-data www-data

USER www-data
