#!/usr/bin/env bash
set -euo pipefail

cd /var/www/html

git config --global --add safe.directory /var/www/html 2>/dev/null || true

fix_permissions() {
    mkdir -p storage/framework/{cache,sessions,views} storage/logs bootstrap/cache
    chown -R www-data:www-data storage bootstrap/cache 2>/dev/null || true
    chmod -R ug+rwx storage bootstrap/cache 2>/dev/null || true
}

wait_for_db() {
    if [ "${DB_CONNECTION:-}" != "pgsql" ]; then
        return 0
    fi

    echo "Waiting for PostgreSQL at ${DB_HOST:-postgres}:${DB_PORT:-5432}..."
    for _ in $(seq 1 30); do
        if php -r "
            try {
                new PDO(
                    'pgsql:host=' . getenv('DB_HOST') . ';port=' . getenv('DB_PORT') . ';dbname=' . getenv('DB_DATABASE'),
                    getenv('DB_USERNAME'),
                    getenv('DB_PASSWORD')
                );
                exit(0);
            } catch (Throwable \$e) {
                exit(1);
            }
        "; then
            echo "PostgreSQL is ready."
            return 0
        fi
        sleep 2
    done

    echo "PostgreSQL did not become ready in time." >&2
    exit 1
}

bootstrap_app() {
    fix_permissions

    if [ ! -f vendor/autoload.php ]; then
        echo "Installing Composer dependencies..."
        composer install --no-interaction --prefer-dist
        fix_permissions
    fi

    # Prefer APP_KEY from environment (Docker). Fall back to generating into .env.
    if [ -z "${APP_KEY:-}" ] || [[ "${APP_KEY}" != base64:* ]]; then
        if [ ! -f .env ]; then
            echo "Creating .env..."
            touch .env
        fi
        if ! grep -qE '^APP_KEY=base64:' .env 2>/dev/null; then
            echo "Generating application key..."
            php artisan key:generate --force --no-interaction
            # Export so later artisan commands (config:cache) see it
            export APP_KEY="$(grep -E '^APP_KEY=base64:' .env | head -1 | cut -d= -f2-)"
        fi
    fi

    if [ "${RUN_MIGRATIONS:-true}" = "true" ]; then
        echo "Running database migrations..."
        php artisan migrate --force --no-interaction
    fi

    if [ "${APP_ENV:-local}" = "production" ]; then
        php artisan config:cache --no-interaction
        php artisan route:cache --no-interaction
        php artisan view:cache --no-interaction
    fi

    fix_permissions
}

wait_for_db
bootstrap_app

exec "$@"
