FROM php:8.2-cli

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    sqlite3 \
    libsqlite3-dev \
    libicu-dev \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install \
    pdo_mysql \
    pdo_sqlite \
    mbstring \
    exif \
    pcntl \
    bcmath \
    gd \
    zip \
    intl \
    xml \
    soap

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy composer files first for better caching
COPY composer.json composer.lock ./

# Install dependencies (without scripts to avoid errors)
RUN composer install --no-dev --optimize-autoloader --no-scripts --no-interaction

# Copy application code
COPY . /var/www

# Run composer scripts after copying all files
RUN composer dump-autoload --optimize

# Create database file
RUN touch /var/www/database/database.sqlite

# Set permissions
RUN chmod -R 755 /var/www/storage /var/www/bootstrap/cache

# Expose HTTP port (platforms like Render set $PORT at runtime)
EXPOSE 8000

# php artisan serve listens on HTTP - required for platforms that scan for HTTP ports.
# $PORT is set by Render/Railway etc.; fallback to 8000 for local Docker.
CMD ["sh", "-c", "php artisan serve --host=0.0.0.0 --port=${PORT:-8000}"]
