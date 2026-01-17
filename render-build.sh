#!/bin/bash
set -e

echo "🚀 Starting Render build process..."

# Install dependencies
echo "📦 Installing Composer dependencies..."
composer install --no-dev --optimize-autoloader --no-interaction || {
    echo "❌ Composer install failed"
    exit 1
}

echo "📦 Installing NPM dependencies..."
npm install || {
    echo "❌ NPM install failed"
    exit 1
}

echo "🔨 Building frontend assets..."
npm run build-only || {
    echo "⚠️ Frontend build failed, continuing anyway..."
}

# Create necessary directories
echo "📁 Creating directories..."
mkdir -p storage/framework/{sessions,views,cache}
mkdir -p storage/logs
mkdir -p bootstrap/cache

# Create database file (use absolute path if DB_DATABASE is set, otherwise relative)
if [ -n "$DB_DATABASE" ]; then
    DB_PATH="$DB_DATABASE"
    DB_DIR=$(dirname "$DB_PATH")
    mkdir -p "$DB_DIR"
    touch "$DB_PATH"
    chmod 664 "$DB_PATH"
    echo "💾 Created database at: $DB_PATH"
else
    touch database/database.sqlite
    chmod 664 database/database.sqlite
    echo "💾 Created database at: database/database.sqlite"
fi

# Set permissions
echo "🔐 Setting permissions..."
chmod -R 775 storage bootstrap/cache || true

# Generate application key if not set
if [ -z "$APP_KEY" ]; then
    echo "🔑 Generating application key..."
    php artisan key:generate --force || {
        echo "⚠️ Key generation failed, will try again at runtime"
    }
else
    echo "🔑 Application key already set"
fi

# Run migrations
echo "🗄️ Running migrations..."
php artisan migrate --force || {
    echo "⚠️ Migrations failed, will try again at runtime"
}

# Cache configuration
echo "⚡ Caching configuration..."
php artisan config:cache || {
    echo "⚠️ Config cache failed"
}
php artisan route:cache || {
    echo "⚠️ Route cache failed"
}
php artisan view:cache || {
    echo "⚠️ View cache failed"
}

echo "✅ Build completed successfully!"
