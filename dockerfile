FROM nextcloud:32.0.3-fpm-alpine

# 1. Install Nginx and extensions (Production Best)
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN apk add --no-cache nginx && \
    install-php-extensions gd zip pdo_mysql intl bcmath apcu opcache

# 2. Put code directly in the webroot
WORKDIR /var/www/html
RUN cp -at . /usr/src/nextcloud/

# 3. Create the directories we want to be mutable
RUN mkdir -p data config custom_apps

# 4. Strict Permissions: Root owns the code, 1003 owns the state
RUN chown -R root:root /var/www/html && \
    chown -R 1003:1003 /var/www/html/data \
                       /var/www/html/config \
                       /var/www/html/custom_apps \
                       /usr/local/etc/php/conf.d

USER 1003