FROM php:7.2-fpm-buster

ARG APP_ID=1000

# Configure the gd library
RUN apt-get update && apt-get install -y \
  cron \
  git \
  gzip \
  libbz2-dev \
  libfreetype6-dev \
  libicu-dev \
  libjpeg62-turbo-dev \
  libmcrypt-dev \
  libpng-dev \
  libsodium-dev \
  libssh2-1-dev \
  libxslt1-dev \
  lsof \
  default-mysql-client \
  vim \
  zip

RUN docker-php-ext-configure \
  gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/

RUN docker-php-ext-install \
  bcmath \
  bz2 \
  calendar \
  exif \
  gd \
  gettext \
  intl \
  mbstring \
  mysqli \
  opcache \
  pcntl \
  pdo_mysql \
  soap \
  sockets \
  sodium \
  sysvmsg \
  sysvsem \
  sysvshm \
  xsl \
  zip

RUN groupadd -g "$APP_ID" app \
  && useradd -g "$APP_ID" -u "$APP_ID" -d /var/www -s /bin/bash app


# Install NODEJS
RUN apt-get install -y gnupg \
  && curl -sL https://deb.nodesource.com/setup_14.x | bash - \
  && apt-get install -y nodejs \
  && mkdir /var/www/.config /var/www/.npm \
  && chown app:app /var/www/.config /var/www/.npm \
  && npm install -g grunt-cli

RUN apt-get install -y msmtp mailutils
COPY conf/msmtprc /etc/msmtprc

# # Install GOSU and other packages
# RUN apt-get install -y \
#     gosu \
#     bc

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer --version=1.10.17

RUN curl -s https://packages.blackfire.io/gpg.key | apt-key add - \
  && echo "deb http://packages.blackfire.io/debian any main" | tee /etc/apt/sources.list.d/blackfire.list \
  && apt-get update \
  && apt-get install blackfire-agent blackfire-php
  
# # Install Magerun2 from n98
# RUN curl -O https://files.magerun.net/n98-magerun2.phar; \
#     chmod +x ./n98-magerun2.phar; \
#     mv ./n98-magerun2.phar /usr/local/bin/n98-magerun2


COPY conf/www.conf /usr/local/etc/php-fpm.d/
COPY conf/php.ini /usr/local/etc/php/
COPY conf/php-fpm.conf /usr/local/etc/

RUN mkdir -p /etc/nginx/html /var/www/html /sock \
  && chown -R app:app /etc/nginx /var/www /usr/local/etc/php/conf.d /sock

USER app:app

VOLUME /var/www

WORKDIR /var/www/html

EXPOSE 9001