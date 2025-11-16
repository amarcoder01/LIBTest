# LibreSpeed Modern UI - Docker Configuration for Render
FROM php:8.1-apache

# Install required PHP extensions
RUN docker-php-ext-install -j$(nproc) opcache

# Enable Apache modules
RUN a2enmod rewrite headers

# Set working directory
WORKDIR /var/www/html

# Copy all project files
COPY . /var/www/html/

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html \
    && chmod -R 777 /var/www/html/backend \
    && chmod -R 777 /var/www/html/results

# Configure Apache
RUN echo 'ServerName localhost' >> /etc/apache2/apache2.conf

# Create Apache configuration for LibreSpeed
RUN echo '<VirtualHost *:80>\n\
    DocumentRoot /var/www/html\n\
    <Directory /var/www/html>\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>\n\
    <Directory /var/www/html/backend>\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>\n\
    ErrorLog ${APACHE_LOG_DIR}/error.log\n\
    CustomLog ${APACHE_LOG_DIR}/access.log combined\n\
</VirtualHost>' > /etc/apache2/sites-available/000-default.conf

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/backend/empty.php || exit 1

# Start Apache
CMD ["apache2-foreground"]
