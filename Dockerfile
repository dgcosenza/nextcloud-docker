# syntax=docker/dockerfile:1.7

ARG DEBIAN_BASE=debian:trixie-slim@sha256:8aa5a7bf5a1955bddbe7d74fcdd0b91ab30e74362a8b73af672b0481b35b44a0
ARG NGINX_VERSION=1.30.8
ARG NGX_BROTLI_COMMIT=53e0fb55f250f48fe80c0ddbf6c0f7103cdbaae1
ARG NEXTCLOUD_VERSION=35.0.3
ARG COMPOSER_VERSION=2.8.12
ARG COMPOSER_SHA256=f446ea719708bb85fcbf4ef18def5d0515f1f9b4d703f6d820c9c1656e10a2f2

# ---- Stage 1: compile official NGINX stable (HTTP/3 + ngx_brotli) ----
FROM ${DEBIAN_BASE} AS nginx-builder
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG NGINX_VERSION
ARG NGX_BROTLI_COMMIT
ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /src

RUN set -eux; \
    apt-get update; \
    apt-get -y upgrade; \
    apt-get install -y --no-install-recommends \
      build-essential ca-certificates curl dpkg-dev git libbrotli-dev libpcre2-dev \
      libssl-dev zlib1g-dev; \
    rm -rf /var/lib/apt/lists/*; \
    curl -fsSLo /src/nginx.tar.gz "https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz"; \
    tar -xzf /src/nginx.tar.gz -C /src; \
    mv "/src/nginx-${NGINX_VERSION}" /src/nginx; \
    git init /src/ngx_brotli; \
    git -C /src/ngx_brotli remote add origin https://github.com/google/ngx_brotli.git; \
    git -C /src/ngx_brotli fetch --depth 1 origin "${NGX_BROTLI_COMMIT}"; \
    git -C /src/ngx_brotli checkout --detach FETCH_HEAD; \
    test "$(git -C /src/ngx_brotli rev-parse HEAD)" = "${NGX_BROTLI_COMMIT}"; \
    mkdir -p /src/ngx_brotli/deps/brotli/c; \
    ln -s /usr/include /src/ngx_brotli/deps/brotli/c/include; \
    ln -s "/usr/lib/$(dpkg-architecture -qDEB_HOST_MULTIARCH)" /src/ngx_brotli/deps/brotli/out

WORKDIR /src/nginx

RUN set -eux; \
    ./configure \
      --prefix=/var/lib/nginx \
      --sbin-path=/usr/sbin/nginx \
      --modules-path=/usr/lib/nginx/modules \
      --conf-path=/etc/nginx/nginx.conf \
      --error-log-path=/var/log/nginx/error.log \
      --http-log-path=/var/log/nginx/access.log \
      --pid-path=/run/nginx.pid \
      --lock-path=/run/nginx.lock \
      --http-client-body-temp-path=/var/lib/nginx/tmp/client_body \
      --http-proxy-temp-path=/var/lib/nginx/tmp/proxy \
      --http-fastcgi-temp-path=/var/lib/nginx/tmp/fastcgi \
      --http-uwsgi-temp-path=/var/lib/nginx/tmp/uwsgi \
      --http-scgi-temp-path=/var/lib/nginx/tmp/scgi \
      --user=abc \
      --group=abc \
      --with-compat \
      --with-threads \
      --with-file-aio \
      --with-pcre-jit \
      --with-http_ssl_module \
      --with-http_v2_module \
      --with-http_v3_module \
      --with-http_realip_module \
      --with-http_addition_module \
      --with-http_sub_module \
      --with-http_dav_module \
      --with-http_gunzip_module \
      --with-http_gzip_static_module \
      --with-http_auth_request_module \
      --with-http_slice_module \
      --with-http_stub_status_module \
      --add-dynamic-module=/src/ngx_brotli; \
    make -j"$(nproc)"; \
    make DESTDIR=/out install; \
    rm -rf /out/var/log/nginx

# ---- Stage 2: download & SHA-256 verify official Nextcloud release, patch bundled deps ----
FROM ${DEBIAN_BASE} AS nextcloud-src
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG NEXTCLOUD_VERSION
ARG COMPOSER_VERSION
ARG COMPOSER_SHA256
ARG DEBIAN_FRONTEND=noninteractive

COPY patches/webauthn-lib-backport.patch /tmp/webauthn-lib-backport.patch
COPY patches/webauthn-lib-composer.json /tmp/webauthn-lib-composer.json

RUN set -eux; \
    apt-get update; \
    apt-get -y upgrade; \
    apt-get install -y --no-install-recommends \
      bzip2 ca-certificates curl jq patch php8.4-cli php8.4-curl php8.4-mbstring \
      php8.4-xml php8.4-zip tar unzip; \
    rm -rf /var/lib/apt/lists/*; \
    mkdir -p /app/www/src; \
    curl -fsSLo /tmp/nextcloud.tar.bz2 "https://download.nextcloud.com/server/releases/nextcloud-${NEXTCLOUD_VERSION}.tar.bz2"; \
    curl -fsSLo /tmp/nextcloud.tar.bz2.sha256 "https://download.nextcloud.com/server/releases/nextcloud-${NEXTCLOUD_VERSION}.tar.bz2.sha256"; \
    EXPECTED_SHA="$(awk -v f="nextcloud-${NEXTCLOUD_VERSION}.tar.bz2" '$2 == f {print $1; exit}' /tmp/nextcloud.tar.bz2.sha256)"; \
    test -n "${EXPECTED_SHA}"; \
    echo "${EXPECTED_SHA}  /tmp/nextcloud.tar.bz2" | sha256sum -c -; \
    tar -xjf /tmp/nextcloud.tar.bz2 -C /app/www/src --strip-components=1; \
    rm -rf /app/www/src/updater /tmp/nextcloud.tar.bz2 /tmp/nextcloud.tar.bz2.sha256; \
    mkdir -p /app/www/src/data; \
    chmod 0755 /app/www/src/occ; \
    curl -fsSLo /usr/local/bin/composer "https://getcomposer.org/download/${COMPOSER_VERSION}/composer.phar"; \
    echo "${COMPOSER_SHA256}  /usr/local/bin/composer" | sha256sum -c -; \
    chmod 0755 /usr/local/bin/composer; \
    cp -a /app/www/src/3rdparty/web-auth/webauthn-lib /opt/webauthn-lib-patched; \
    patch -d /opt/webauthn-lib-patched -p1 < /tmp/webauthn-lib-backport.patch; \
    cp /tmp/webauthn-lib-composer.json /opt/webauthn-lib-patched/composer.json

WORKDIR /app/www/src/3rdparty

RUN set -eux; \
    composer config repositories.webauthn-lib-patched '{"type":"path","url":"/opt/webauthn-lib-patched","options":{"symlink":false}}'; \
    jq '.require["symfony/filesystem"] = "^7.4.23" | .require["symfony/http-foundation"] = "^7.4.23" | .require["symfony/mailer"] = "^7.4.24" | .require["symfony/routing"] = "^6.4.51" | .require["web-auth/webauthn-lib"] = "5.3.5"' composer.json > /tmp/3rdparty-composer.json; \
    mv /tmp/3rdparty-composer.json composer.json; \
    composer update --no-interaction --prefer-dist --with-all-dependencies \
      symfony/filesystem symfony/http-foundation symfony/mailer symfony/routing web-auth/webauthn-lib

# ---- Stage 3: hardened Debian 13 (trixie-slim) Nextcloud runtime ----
FROM ${DEBIAN_BASE} AS runtime
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG NGINX_VERSION
ARG NEXTCLOUD_VERSION
ARG BUILD_DATE=unknown
ARG IMAGE_REVISION=""
ARG IMAGE_SOURCE="https://github.com/dgcosenza/nextcloud-docker"
ARG DEBIAN_FRONTEND=noninteractive

RUN set -eux; \
    apt-get update; \
    apt-get -y upgrade; \
    apt-get install -y --no-install-recommends \
      ca-certificates curl ffmpeg imagemagick jq libbrotli1 libpcre2-8-0 \
      libssl3t64 openssl passwd procps rsync smbclient tini tzdata util-linux zlib1g \
      php8.4-fpm php8.4-cli php8.4-bcmath php8.4-bz2 php8.4-curl \
      php8.4-gd php8.4-gmp php8.4-intl php8.4-ldap php8.4-mbstring \
      php8.4-mysql php8.4-pgsql php8.4-soap php8.4-sqlite3 php8.4-xml \
      php8.4-xsl php8.4-zip php-apcu php-igbinary php-imagick \
      php-memcached php-msgpack php-redis php-smbclient; \
    groupadd --gid 1000 abc; \
    useradd --uid 1000 --gid 1000 --create-home --home-dir /config \
      --shell /bin/bash --comment 'Nextcloud service user' abc; \
    mkdir -p /etc/nginx/modules /etc/nginx/conf.d /etc/nginx/http.d \
      /var/lib/nginx/tmp/client_body /var/lib/nginx/tmp/proxy \
      /var/lib/nginx/tmp/fastcgi /var/lib/nginx/tmp/uwsgi /var/lib/nginx/tmp/scgi \
      /var/log/nginx /run/php /app/www/public /defaults /config /data; \
    printf 'include /config/nginx/nginx.conf;\n' > /etc/nginx/nginx.conf; \
    printf 'load_module /usr/lib/nginx/modules/ngx_http_brotli_filter_module.so;\nload_module /usr/lib/nginx/modules/ngx_http_brotli_static_module.so;\n' \
      > /etc/nginx/modules/10_http_brotli.conf; \
    chown -R abc:abc /var/lib/nginx /var/log/nginx /run/php /app/www/public; \
    { \
      echo 'apc.enable_cli=1'; \
      echo 'opcache.enable=1'; \
      echo 'opcache.interned_strings_buffer=32'; \
      echo 'opcache.max_accelerated_files=10000'; \
      echo 'opcache.memory_consumption=128'; \
      echo 'opcache.save_comments=1'; \
      echo 'opcache.revalidate_freq=60'; \
      echo 'opcache.jit=1255'; \
      echo 'opcache.jit_buffer_size=8M'; \
      echo 'memory_limit=512M'; \
      echo 'upload_max_filesize=100G'; \
      echo 'post_max_size=100G'; \
      echo 'max_input_time=3600'; \
      echo 'max_execution_time=3600'; \
      echo 'output_buffering=0'; \
      echo 'expose_php=Off'; \
    } > /etc/php/8.4/mods-available/nextcloud.ini; \
    ln -sfn /etc/php/8.4/mods-available/nextcloud.ini /etc/php/8.4/fpm/conf.d/90-nextcloud.ini; \
    ln -sfn /etc/php/8.4/mods-available/nextcloud.ini /etc/php/8.4/cli/conf.d/90-nextcloud.ini; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=nginx-builder --chown=0:0 /out/usr/sbin/nginx /usr/sbin/nginx
COPY --from=nginx-builder --chown=0:0 /out/usr/lib/nginx/modules /usr/lib/nginx/modules
COPY --from=nginx-builder --chown=0:0 /out/etc/nginx/mime.types /etc/nginx/mime.types
COPY --from=nginx-builder --chown=0:0 /out/etc/nginx/fastcgi_params /etc/nginx/fastcgi_params
COPY --from=nginx-builder --chown=0:0 /out/etc/nginx/fastcgi.conf /etc/nginx/fastcgi.conf
COPY --from=nextcloud-src --chown=0:0 /app/www/src /app/www/src
COPY defaults/ /defaults/
COPY --chmod=0755 scripts/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY --chmod=0755 scripts/occ /usr/local/bin/occ

ENV PUID=1000 \
    PGID=1000 \
    TZ=Etc/UTC \
    NEXTCLOUD_CRON_INTERVAL=300

EXPOSE 80 443
VOLUME ["/config", "/data"]

HEALTHCHECK --interval=30s --timeout=10s --start-period=180s --retries=3 \
    CMD ["sh", "-c", "curl -fsSk https://127.0.0.1:443/status.php >/dev/null || exit 1"]

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/docker-entrypoint.sh"]

LABEL org.opencontainers.image.title="Nextcloud (Debian 13 / NGINX 1.30 / PHP 8.4)" \
      org.opencontainers.image.description="Hardened multi-arch Debian 13 (trixie-slim) Nextcloud container with source-built NGINX 1.30 (HTTP/3 + Brotli) and PHP 8.4 FPM, maintained by Daniel G. Cosenza from FNX Labs." \
      org.opencontainers.image.url="https://hub.docker.com/r/dgcosenza/nextcloud" \
      org.opencontainers.image.source="${IMAGE_SOURCE}" \
      org.opencontainers.image.documentation="${IMAGE_SOURCE}#readme" \
      org.opencontainers.image.version="${NEXTCLOUD_VERSION}" \
      org.opencontainers.image.revision="${IMAGE_REVISION}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.licenses="AGPL-3.0-or-later AND MIT" \
      org.opencontainers.image.vendor="Daniel G. Cosenza from FNX Labs" \
      org.opencontainers.image.authors="Daniel G. Cosenza from FNX Labs" \
      org.opencontainers.image.base.name="debian:trixie-slim" \
      io.github.dgcosenza.nextcloud.upstream_version="${NEXTCLOUD_VERSION}" \
      io.github.dgcosenza.nextcloud.nginx_version="${NGINX_VERSION}"
