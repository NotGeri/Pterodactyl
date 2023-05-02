FROM --platform=$TARGETOS/$TARGETARCH php:8.1-fpm-alpine
RUN apk add --no-cache --update ca-certificates dcron curl git supervisor tar unzip nginx libpng-dev libxml2-dev libzip-dev certbot certbot-nginx  \
    && docker-php-ext-configure zip \
    && docker-php-ext-install bcmath gd pdo_mysql zip \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN rm /usr/local/etc/php-fpm.conf \
    && echo "* * * * * /usr/local/bin/php /app/artisan schedule:run >> /dev/null 2>&1" >> /var/spool/cron/crontabs/root \
    && echo "0 23 * * * certbot renew --nginx --quiet" >> /var/spool/cron/crontabs/root \
    && sed -i s/ssl_session_cache/#ssl_session_cache/g /etc/nginx/nginx.conf \
    && mkdir -p /var/run/php /var/run/nginx

# Install Node.js v14
RUN echo "https://dl-cdn.alpinelinux.org/alpine/v3.14/main" >> /etc/apk/repositories \
    && echo "https://dl-cdn.alpinelinux.org/alpine/v3.14/community" >> /etc/apk/repositories \
    && apk add --no-cache "nodejs<15" "npm<8"

RUN node --version
RUN npm i -g yarn

# Install xDebug
RUN wget https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions \
    && chmod +x install-php-extensions \
    && ./install-php-extensions xdebug \
    && rm -rf /usr/local/etc/php/conf.d/*xdebug*

# Copy other config files
COPY php/xdebug.ini /usr/local/etc/php/conf.d/
COPY nginx/default.conf /etc/nginx/http.d/default.conf
COPY nginx/www.conf /usr/local/etc/php-fpm.conf
COPY supervisord/supervisord.conf /etc/supervisord.conf
COPY docker/entrypoint.sh /entrypoint.sh

# Expose ports & start entrypoint and supervisord process
WORKDIR /app/
EXPOSE 80 443
ENTRYPOINT [ "/bin/ash", "/entrypoint.sh" ]
CMD [ "supervisord", "-n", "-c", "/etc/supervisord.conf" ]
