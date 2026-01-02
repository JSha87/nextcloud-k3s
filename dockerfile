FROM nextcloud:32.0.3-fpm-alpine

# 1. Install Nginx and extensions
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN apk add --no-cache nginx && \
    install-php-extensions gd zip pdo_mysql intl bcmath apcu opcache

# 2. Force copy source to webroot
RUN cp -rav /usr/src/nextcloud/. /var/www/html/

# 3. Create the mutable directories
RUN mkdir -p /var/www/html/data /var/www/html/config /var/www/html/custom_apps

# 4. THE SECURITY FIX: 
# Root owns the code (Immutable to the app)
# User 1003 owns only the folders that NEED to be writable
RUN chown -R root:root /var/www/html && \
    chown -R 1003:1003 /var/www/html/data \
                       /var/www/html/config \
                       /var/www/html/custom_apps \
                       /usr/local/etc/php/conf.d && \
    chmod -R 755 /var/www/html

USER 1003
WORKDIR /var/www/html