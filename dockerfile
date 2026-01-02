FROM nextcloud:32.0.3-fpm-alpine

# 1. Grab the professional extension installer
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

# 2. Install all required modules in one clean layer
# This handles build-deps, compilation, and cleanup automatically
RUN install-php-extensions gd zip pdo_mysql intl bcmath apcu opcache

# 3. Bake the code into the image (Immutable Webroot)
RUN cp -at /var/www/html /usr/src/nextcloud/

# 4. Create persistence points and set strict ownership
# We only give user 1003 rights to what they MUST change
RUN mkdir -p /var/www/html/data /var/www/html/config /var/www/html/custom_apps && \
    chown -R 1003:1003 /var/www/html/data \
                       /var/www/html/config \
                       /var/www/html/custom_apps \
                       /usr/local/etc/php/conf.d

# 5. Production PHP Tuning
RUN echo "memory_limit=512M" > /usr/local/etc/php/conf.d/memory-limit.ini && \
    echo "opcache.enable=1" > /usr/local/etc/php/conf.d/opcache-recommended.ini

USER 1003
WORKDIR /var/www/html