# Stage 1: Build
FROM php:8.2-fpm-alpine AS build

WORKDIR /var/www/html

# Install system dependencies and PHP extensions required by Laravel
RUN apk add --no-cache bash git unzip curl libzip-dev oniguruma-dev \
    && docker-php-ext-install pdo pdo_mysql mbstring zip bcmath

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy composer files and install dependencies WITHOUT running scripts
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader --no-scripts

# Copy full project
COPY . .

# Stage 2: Serve
FROM nginx:alpine

WORKDIR /var/www/html

# Copy built app from Stage 1
COPY --from=build /var/www/html /var/www/html

# Copy Nginx config
COPY .docker/nginx/default.conf /etc/nginx/conf.d/default.conf

# Expose port
EXPOSE 80

# Run PHP-FPM and Nginx together, also run package discovery at container start
CMD ["sh", "-c", "php artisan package:discover --ansi && php-fpm -D && nginx -g 'daemon off;'"]
