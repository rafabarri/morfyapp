FROM php:8.1-apache

# Instalar dependencias para php y composer
RUN apt-get update && apt-get install -y \
    libzip-dev zip unzip git curl \
    && docker-php-ext-install pdo pdo_mysql zip

# Instalar Composer globalmente
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Habilitar mod_rewrite de Apache
RUN a2enmod rewrite

# Copiar todo el código al contenedor
COPY . /var/www/html/

# Ejecutar composer install dentro del directorio del proyecto
RUN cd /var/www/html && composer install --no-interaction --prefer-dist --optimize-autoloader

# Cambiar permisos para apache
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage

# Exponer puerto 80
EXPOSE 80

CMD ["apache2-foreground"]
