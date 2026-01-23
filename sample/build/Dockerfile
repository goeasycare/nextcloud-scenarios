FROM php:8.2-fpm-alpine

# 1. Install permanent dependencies and temporary build tools
RUN apk add --no-cache \
  freetype-dev \
  libjpeg-turbo-dev \
  libpng-dev \
  libwebp-dev \
  libzip-dev \
  icu-dev \
  sqlite-dev \
  rsync \
  curl \
  # Added these for PECL/Redis support
  autoconf \
  g++ \
  make \
  libtool \
  && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
  && docker-php-ext-install -j$(nproc) \
  gd \
  intl \
  pdo_mysql \
  pdo_sqlite \
  zip \
  opcache \
  bcmath \
  # --- REDIS ADDITION STARTS HERE ---
  && pecl install redis \
  && docker-php-ext-enable redis \
  # --- REDIS ADDITION ENDS HERE ---
  # Cleanup: Remove build tools to save space
  && apk del autoconf g++ make libtool

# Copy your existing PHP optimizations
# Note: Ensure this file exists in the build context (sample/build/)
COPY sample/build/php-optimization.ini /usr/local/etc/php/conf.d/php-optimization.ini

WORKDIR /var/www/html

# Download and install Nextcloud
ENV NEXTCLOUD_VERSION=28.0.0
RUN curl -fsSL -o nextcloud.tar.bz2 \
  "https://download.nextcloud.com/server/releases/nextcloud-${NEXTCLOUD_VERSION}.tar.bz2" && \
  tar -xjf nextcloud.tar.bz2 --strip-components=1 && \
  rm nextcloud.tar.bz2 && \
  chown -R www-data:www-data /var/www/html

# Add entrypoint script
COPY sample/build/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 9000
ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]
