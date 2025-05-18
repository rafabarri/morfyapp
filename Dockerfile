# Usamos la imagen oficial de PHP con Apache y versión 8.1
FROM php:8.1-apache

# Instalamos extensiones necesarias y utilidades
RUN apt-get update && apt-get install -y \
    libzip-dev zip unzip git curl \
    && docker-php-ext-install pdo pdo_mysql zip

# Instala Composer manualmente
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copiamos solo archivos de dependencias primero (para usar cache si no cambian)
COPY composer.json composer.lock /var/www/html/

# Instalamos dependencias de PHP
RUN cd /var/www/html && composer install --no-interaction --prefer-dist --optimize-autoloader

# Copiamos el resto del proyecto
COPY . /var/www/html/

# Habilitamos mod_rewrite de Apache para rutas amigables
RUN a2enmod rewrite

# Cambiamos permisos para que Apache pueda acceder a los archivos
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage

# Exponemos el puerto 80 para acceder vía navegador
EXPOSE 80

# Comando para arrancar Apache en primer plano
CMD ["apache2-foreground"]
