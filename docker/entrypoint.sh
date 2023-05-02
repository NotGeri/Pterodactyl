#!/bin/ash -e
cd /app

# Clean up temporary files
rm -rf bootstrap/cache/*.php \
  public/assets/*.js \
  public/assets/manifest.json

mkdir -p bootstrap/cache/ \
  storage/logs/ \
  storage/framework/sessions/ \
  storage/framework/views/ \
  storage/framework/cache/ \
  /var/log/supervisord/

# Run composer
composer update

# Run Yarn/NPM
yarn

# Clean up file permissions
chmod 777 -R bootstrap/ storage/
chown -R nginx:nginx .

# Check for .env file and generate app keys if missing
if [ ! -f .env ]; then
  echo ".env does not exist"
  touch .env

  if [ -z "$APP_KEY" ]; then
    echo "Generating key."
    APP_KEY=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
    echo "Generated app key: $APP_KEY"
    echo "APP_KEY=$APP_KEY" >.env
  else
    echo "APP_KEY exists in environment, using that."
    echo "APP_KEY=$APP_KEY" >.env
  fi
fi

# Check for DB up before starting the panel
echo "Checking database status"
until nc -z -v -w30 "$DB_HOST" "$DB_PORT"; do
  echo "Waiting for database connection..."
  sleep 1
done

# Migrate & seed depending on the context
if [ ! -f storage/.migrated ]; then
  php artisan migrate --seed --force
  touch storage/.migrated
else
  php artisan migrate --force
fi

# Start cronjobs for the queue
echo "Starting cron jobs."
crond -L /var/log/crond -l 5

# Proceed to start supervisord
echo "Starting supervisord."
exec "$@"
