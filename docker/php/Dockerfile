FROM php:8-fpm

RUN pecl install -o -f redis \
    && rm -rf /tmp/pear \
    && docker-php-ext-enable redis

RUN apt-get update && apt-get install -y libpq-dev \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pdo pgsql pdo_pgsql

WORKDIR /app

#ENTRYPOINT ["php", "-S", "0.0.0.0:8000", "-t", "/app/public"]
#CMD ["php-fpm"]