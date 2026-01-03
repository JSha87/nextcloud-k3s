FROM nextcloud:32.0.3-fpm-alpine

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN apk add --no-cache nginx && \
    install-php-extensions gd zip pdo_mysql intl bcmath apcu opcache

RUN cp -rav /usr/src/nextcloud/. /var/www/html/

RUN mkdir -p /var/www/html/data /var/www/html/config /var/www/html/custom_apps

# Patch entrypoint to use /tmp for lock file (RECOMMENDED)
RUN sed -i 's|/var/www/html/nextcloud-init-sync.lock|/tmp/nextcloud-init-sync.lock|g' /entrypoint.sh

RUN chown -R root:root /var/www/html && \
    chown -R 1003:1003 /var/www/html/data \
                       /var/www/html/config \
                       /var/www/html/custom_apps \
                       /usr/local/etc/php/conf.d && \
    chmod -R 755 /var/www/html

USER 1003
WORKDIR /var/www/html