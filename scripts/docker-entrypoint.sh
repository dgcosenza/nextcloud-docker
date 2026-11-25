#!/usr/bin/env bash
set -euo pipefail

PUID="${PUID:-1000}"
PGID="${PGID:-1000}"

if [ "$(id -u)" -eq 0 ]; then
  if [ "$(id -g abc)" != "$PGID" ]; then
    groupmod -o -g "$PGID" abc
  fi
  if [ "$(id -u abc)" != "$PUID" ]; then
    usermod -o -u "$PUID" abc
  fi
fi

run_as_abc() {
  if [ "$(id -u)" -eq 0 ]; then
    setpriv --reuid="$PUID" --regid="$PGID" --init-groups env HOME=/config USER=abc "$@"
  else
    "$@"
  fi
}

mkdir -p \
  /config/nginx/site-confs \
  /config/keys \
  /config/log/nginx \
  /config/log/php \
  /config/php \
  /config/www/nextcloud/apps \
  /config/www/nextcloud/config \
  /config/www/nextcloud/themes \
  /app/www/public \
  /data \
  /var/lib/nginx/tmp/client_body \
  /var/lib/nginx/tmp/proxy \
  /var/lib/nginx/tmp/fastcgi \
  /var/lib/nginx/tmp/uwsgi \
  /var/lib/nginx/tmp/scgi \
  /run/php

# Seed default NGINX/TLS/PHP config files only if absent
if [ ! -f /config/nginx/worker_processes.conf ]; then
  printf 'worker_processes auto;\n' > /config/nginx/worker_processes.conf
fi
if [ ! -f /config/nginx/resolver.conf ]; then
  NS="$(awk '/^nameserver[[:space:]]+/{print $2; exit}' /etc/resolv.conf || true)"
  [ -n "$NS" ] || NS="127.0.0.11"
  case "$NS" in *:*) NS="[${NS}]" ;; esac
  printf 'resolver %s valid=30s;\n' "$NS" > /config/nginx/resolver.conf
fi
if [ ! -f /config/nginx/dhparams.pem ]; then
  cp /defaults/dhparams.pem /config/nginx/dhparams.pem
fi
if [ ! -f /config/keys/cert.crt ] || [ ! -f /config/keys/cert.key ]; then
  openssl req -x509 -nodes -newkey rsa:2048 -days 3650 \
    -subj "/CN=localhost" \
    -keyout /config/keys/cert.key \
    -out /config/keys/cert.crt >/dev/null 2>&1
  chmod 0600 /config/keys/cert.key
  chmod 0644 /config/keys/cert.crt
fi

for pair in \
  "nginx.conf:/config/nginx/nginx.conf" \
  "ssl.conf:/config/nginx/ssl.conf" \
  "default.conf:/config/nginx/site-confs/default.conf" \
  "php-local.ini:/config/php/php-local.ini" \
  "www2.conf:/config/php/www2.conf"; do
  src="/defaults/${pair%%:*}"
  dst="${pair#*:}"
  [ -f "$dst" ] || cp "$src" "$dst"
done

ln -sfn /config/php/php-local.ini /etc/php/8.4/fpm/conf.d/99-local.ini
ln -sfn /config/php/php-local.ini /etc/php/8.4/cli/conf.d/99-local.ini

{
  cat /defaults/php-fpm-www.conf
  if [ -f /config/php/www2.conf ]; then
    echo ""
    sed '/^[[:space:]]*\[www\][[:space:]]*$/d' /config/php/www2.conf
  fi
} > /etc/php/8.4/fpm/pool.d/www.conf

sed -i 's|^error_log = .*|error_log = /config/log/php/error.log|' /etc/php/8.4/fpm/php-fpm.conf

# Hydrate /app/www/public from /app/www/src while preserving /config/www/nextcloud/{apps,config,themes}
for dir in apps config themes; do
  if [ "$(readlink /app/www/public/${dir} 2>/dev/null || true)" != "/config/www/nextcloud/${dir}" ]; then
    rm -rf "/app/www/public/${dir}"
    ln -s "/config/www/nextcloud/${dir}" "/app/www/public/${dir}"
  fi
done

IMAGE_VER="$(php -r "require '/app/www/src/version.php'; echo implode('.', \$OC_Version);" 2>/dev/null || echo '0.0.0.0')"
INSTALLED_VER="0.0.0.0"
if [ -f /config/www/nextcloud/config/config.php ]; then
  INSTALLED_VER="$(php -r "require '/config/www/nextcloud/config/config.php'; echo \$CONFIG['version'] ?? '0.0.0.0';" 2>/dev/null || echo '0.0.0.0')"
fi

vergte() { printf '%s\n%s\n' "$2" "$1" | sort -C -V; }
vergt() { ! vergte "$2" "$1"; }

if [ "$INSTALLED_VER" != "0.0.0.0" ] && vergt "$INSTALLED_VER" "$IMAGE_VER"; then
  echo "ERROR: Refusing to downgrade Nextcloud data (${INSTALLED_VER}) to image (${IMAGE_VER})." >&2
  exit 1
fi

# Always sync core application files from /app/www/src into ephemeral /app/www/public (excluding apps, config, themes, data)
rsync -rlD --exclude='/apps/' --exclude='/config/' --exclude='/themes/' --exclude='/data/' /app/www/src/ /app/www/public/

# On first boot or version upgrade, update shipped apps and seed empty config/themes/data dirs
if [ "$INSTALLED_VER" = "0.0.0.0" ] || [ -z "$(ls -A /config/www/nextcloud/apps 2>/dev/null)" ]; then
  rsync -rlD /app/www/src/apps/ /config/www/nextcloud/apps/
  rsync -rlD --ignore-existing /app/www/src/config/ /config/www/nextcloud/config/
  rsync -rlD --ignore-existing /app/www/src/themes/ /config/www/nextcloud/themes/
elif vergt "$IMAGE_VER" "$INSTALLED_VER"; then
  echo "Upgrading Nextcloud core from ${INSTALLED_VER} to ${IMAGE_VER}..."
  if [ -f /app/www/src/core/shipped.json ]; then
    for app in $(jq -r '.shippedApps[]' /app/www/src/core/shipped.json); do
      rm -rf "/config/www/nextcloud/apps/${app}"
    done
  fi
  rsync -rlD /app/www/src/apps/ /config/www/nextcloud/apps/
  rsync -rlD --ignore-existing /app/www/src/themes/ /config/www/nextcloud/themes/
fi

if [ "$(id -u)" -eq 0 ]; then
  chown -R abc:abc /app/www/public /var/lib/nginx /var/log/nginx /run/php /config/log /config/keys
  chown abc:abc /config /config/nginx /config/nginx/site-confs /config/php /config/www /config/www/nextcloud \
    /config/www/nextcloud/apps /config/www/nextcloud/config /config/www/nextcloud/themes /data
  if [ "$INSTALLED_VER" = "0.0.0.0" ]; then
    chown -R abc:abc /config/www/nextcloud/apps /config/www/nextcloud/config /config/www/nextcloud/themes
  fi
fi

# Run occ upgrade automatically when core version increased on an existing instance
if [ "$INSTALLED_VER" != "0.0.0.0" ] && vergt "$IMAGE_VER" "$INSTALLED_VER"; then
  run_as_abc php /app/www/public/occ upgrade --no-interaction || true
fi

/usr/sbin/nginx -t

/usr/sbin/php-fpm8.4 --nodaemonize --fpm-config /etc/php/8.4/fpm/php-fpm.conf &
PHP_PID=$!

# Lightweight background Nextcloud cron loop (no root crond required; no-new-privileges compatible)
CRON_INTERVAL="${NEXTCLOUD_CRON_INTERVAL:-300}"
CRON_PID=""
if [ "$CRON_INTERVAL" -gt 0 ] 2>/dev/null; then
  (
    while true; do
      sleep "$CRON_INTERVAL"
      if [ -f /config/www/nextcloud/config/config.php ]; then
        run_as_abc php -f /app/www/public/cron.php >/dev/null 2>&1 || true
      fi
    done
  ) &
  CRON_PID=$!
fi

NGINX_ARGS=()
if ! grep -Eq '^[[:space:]]*daemon[[:space:]]+off[[:space:]]*;' /config/nginx/nginx.conf; then
  NGINX_ARGS=(-g "daemon off;")
fi

/usr/sbin/nginx "${NGINX_ARGS[@]}" &
NGINX_PID=$!

shutdown_all() {
  [ -n "$CRON_PID" ] && kill -TERM "$CRON_PID" 2>/dev/null || true
  kill -QUIT "$NGINX_PID" 2>/dev/null || true
  kill -QUIT "$PHP_PID" 2>/dev/null || true
  wait "$NGINX_PID" 2>/dev/null || true
  wait "$PHP_PID" 2>/dev/null || true
}
trap shutdown_all TERM INT

wait -n "$NGINX_PID" "$PHP_PID"
STATUS=$?
shutdown_all
exit "$STATUS"
