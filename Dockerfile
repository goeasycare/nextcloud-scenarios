FROM nextcloud:fpm

# Install dependencies and extensions
# libmagickwand-dev is required for imagick
RUN apt-get update && apt-get install -y \
  libmagickwand-dev \
  --no-install-recommends \
  && pecl install imagick redis \
  && docker-php-ext-enable imagick redis \
  && rm -rf /var/lib/apt/lists/*

# Clean up
RUN apt-get clean

# Copy PHP optimization configuration
COPY php-optimization.ini /usr/local/etc/php/conf.d/php-optimization.ini
