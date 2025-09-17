FROM richarvey/nginx-php-fpm:3.1.6

WORKDIR /var/www/html

# Install system dependencies and PHP extensions
RUN apk add --no-cache bash git unzip libzip-dev oniguruma-dev \
    && docker-php-ext-install pdo pdo_mysql mbstring zip bcmath

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy project files
COPY . .

# Install PHP dependencies without running scripts
RUN composer install --no-dev --optimize-autoloader --no-scripts

EXPOSE 80

# Run package discovery at container start and start PHP-FPM + Nginx
CMD ["sh", "-c", "php artisan package:discover --ansi && php-fpm -D && nginx -g 'daemon off;'"]
