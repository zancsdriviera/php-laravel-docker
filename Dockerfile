# Stage 1: Build
FROM php:8.2-fpm-alpine AS build

WORKDIR /var/www/html

COPY composer.json composer.lock ./
RUN apk add --no-cache bash git unzip curl \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer install --no-dev --optimize-autoloader

COPY . .

# Stage 2: Serve
FROM nginx:alpine

COPY --from=build /var/www/html /var/www/html

COPY .docker/nginx/default.conf /etc/nginx/conf.d/default.conf

WORKDIR /var/www/html

EXPOSE 80

CMD ["sh", "-c", "php-fpm -D && nginx -g 'daemon off;'"]

