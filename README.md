# Nextcloud — Debian 13 (trixie-slim) / NGINX 1.30 / PHP 8.4 FPM Image

[![Daily CI](https://github.com/dgcosenza/nextcloud-docker/actions/workflows/daily.yml/badge.svg)](https://github.com/dgcosenza/nextcloud-docker/actions/workflows/daily.yml)
[![OpenSSF Scorecard Workflow](https://github.com/dgcosenza/nextcloud-docker/actions/workflows/scorecard.yml/badge.svg)](https://github.com/dgcosenza/nextcloud-docker/actions/workflows/scorecard.yml)
[![Gitleaks Secret Scan](https://github.com/dgcosenza/nextcloud-docker/actions/workflows/gitleaks.yml/badge.svg)](https://github.com/dgcosenza/nextcloud-docker/actions/workflows/gitleaks.yml)
[![Public Content Check](https://github.com/dgcosenza/nextcloud-docker/actions/workflows/public-check.yml/badge.svg)](https://github.com/dgcosenza/nextcloud-docker/actions/workflows/public-check.yml)
[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/dgcosenza/nextcloud-docker/badge)](https://scorecard.dev/viewer/?uri=github.com/dgcosenza/nextcloud-docker)
[![OpenSSF Best Practices](https://www.bestpractices.dev/projects/17165/badge)](https://www.bestpractices.dev/projects/17165)

[![Trivy + Grype: 0 Fixable CVEs](https://img.shields.io/badge/Trivy%20%2B%20Grype-0%20fixable%20CVEs-brightgreen?logo=trivy&logoColor=white)](https://github.com/dgcosenza/nextcloud-docker/security/code-scanning)
[![Signed: Cosign OIDC](https://img.shields.io/badge/signed-Cosign%20OIDC-blueviolet)](https://github.com/dgcosenza/nextcloud-docker#supply-chain-verification)
[![SLSA Build L3](https://img.shields.io/badge/SLSA-Build%20L3-brightgreen)](https://github.com/dgcosenza/nextcloud-docker/attestations)
[![SBOM: SPDX + CycloneDX](https://img.shields.io/badge/SBOM-SPDX%20%2B%20CycloneDX-0A7BBB?logo=spdx&logoColor=white)](https://github.com/dgcosenza/nextcloud-docker/releases/latest)
[![Base OS](https://img.shields.io/badge/base-Debian%2013%20(trixie--slim)-A81D33?logo=debian&logoColor=white)](https://github.com/dgcosenza/nextcloud-docker/blob/main/Dockerfile)
[![Architectures](https://img.shields.io/badge/arch-amd64%20%7C%20arm64-007ec6?logo=linux&logoColor=white)](https://github.com/dgcosenza/nextcloud-docker#supported-architectures)
[![Healthcheck: CI Verified](https://img.shields.io/badge/healthcheck-CI%20verified-brightgreen?logo=docker&logoColor=white)](https://github.com/dgcosenza/nextcloud-docker#healthcheck)
[![Renovate Enabled](https://img.shields.io/badge/renovate-enabled-1A1F6C?logo=renovate&logoColor=white)](https://github.com/dgcosenza/nextcloud-docker/blob/main/renovate.json)
[![Dependabot Enabled](https://img.shields.io/badge/dependabot-enabled-025E8C?logo=dependabot&logoColor=white)](https://github.com/dgcosenza/nextcloud-docker/blob/main/.github/dependabot.yml)
[![Daily Rebuilds](https://img.shields.io/badge/rebuilds-daily-2088FF?logo=githubactions&logoColor=white)](https://github.com/dgcosenza/nextcloud-docker/actions/workflows/daily.yml)

[![Latest Release](https://img.shields.io/github/v/release/dgcosenza/nextcloud-docker?label=version&logo=github)](https://github.com/dgcosenza/nextcloud-docker/releases/latest)
[![Release Date](https://img.shields.io/github/release-date/dgcosenza/nextcloud-docker?label=released&logo=github)](https://github.com/dgcosenza/nextcloud-docker/releases/latest)
[![Last Commit](https://img.shields.io/github/last-commit/dgcosenza/nextcloud-docker?logo=github)](https://github.com/dgcosenza/nextcloud-docker/commits/main)
[![Docker Pulls](https://img.shields.io/docker/pulls/dgcosenza/nextcloud?logo=docker&logoColor=white)](https://hub.docker.com/r/dgcosenza/nextcloud)
[![Docker Image Size](https://img.shields.io/docker/image-size/dgcosenza/nextcloud/latest?logo=docker&logoColor=white)](https://hub.docker.com/r/dgcosenza/nextcloud)
[![Registries: Docker Hub + GHCR](https://img.shields.io/badge/registries-Docker%20Hub%20%2B%20GHCR-2496ED?logo=docker&logoColor=white)](https://github.com/dgcosenza/nextcloud-docker/pkgs/container/nextcloud)
[![Packaging License: MIT](https://img.shields.io/badge/packaging-MIT-blue?logo=opensourceinitiative&logoColor=white)](https://github.com/dgcosenza/nextcloud-docker/blob/main/LICENSE)
[![Upstream License](https://img.shields.io/badge/upstream-AGPL--3.0--or--later-green?logo=opensourceinitiative&logoColor=white)](https://github.com/nextcloud/server/blob/master/COPYING)
[![GitHub Issues](https://img.shields.io/github/issues/dgcosenza/nextcloud-docker?logo=github)](https://github.com/dgcosenza/nextcloud-docker/issues)
[![FNX Labs Catalog](https://img.shields.io/badge/catalog-FNX%20Labs-0b1020?logo=githubpages&logoColor=white)](https://dgcosenza.github.io/)

A hardened, drop-in **Nextcloud** container image on **Debian 13 (`trixie-slim`)** combining the SHA-256-verified official Nextcloud server release, source-built **NGINX 1.30** (HTTP/3 QUIC + dynamically linked `ngx_brotli`), and **PHP 8.4 FPM**, maintained by **Daniel G. Cosenza from FNX Labs**.

- **Docker Hub:** [`dgcosenza/nextcloud`](https://hub.docker.com/r/dgcosenza/nextcloud)
- **GitHub Container Registry (GHCR):** [`ghcr.io/dgcosenza/nextcloud`](https://github.com/dgcosenza/nextcloud-docker/pkgs/container/nextcloud) (identical signed multi-arch digest)
- **Source Repository:** [`dgcosenza/nextcloud-docker`](https://github.com/dgcosenza/nextcloud-docker)
- **Upstream Application:** [`nextcloud/server`](https://github.com/nextcloud/server) (AGPL-3.0-or-later)
- **Packaging License:** MIT (see [`LICENSE`](https://github.com/dgcosenza/nextcloud-docker/blob/main/LICENSE) and [`THIRD-PARTY-NOTICES.md`](https://github.com/dgcosenza/nextcloud-docker/blob/main/THIRD-PARTY-NOTICES.md))

---

## Overview

`dgcosenza/nextcloud` packages the latest official Nextcloud release on fully upgraded **Debian 13 (`trixie-slim`)**:

- **Drop-in `/config` and `/data` compatibility:** Preserves `PUID`/`PGID` (user `abc`), `/app/www/public` symlinked to `/config/www/nextcloud/{apps,config,themes}`, `/config/nginx/` (supporting HTTP/3 `quic` and `brotli`), `/config/keys/cert.{crt,key}`, `/config/php/{php-local.ini,www2.conf}`, `/data`, and the `occ` CLI helper (`/usr/local/bin/occ`).
- **Full PHP 8.4 & media stack:** Ships PHP 8.4 FPM with `apcu`, `bcmath`, `bz2`, `curl`, `gd`, `gmp`, `igbinary`, `imagick`, `intl`, `ldap`, `mbstring`, `memcached`, `msgpack`, `mysql`, `pgsql`, `redis`, `smbclient`, `soap`, `sqlite3`, `xml`, `xsl`, `zip`, plus `ffmpeg`, `imagemagick`, and `smbclient`.
- **Downgrade protection & background cron:** Refuses to start if mounted data is newer than the image release, runs `occ upgrade` automatically on core upgrades, and executes `cron.php` every 5 minutes as non-root `abc` without needing setuid `crond` (100% compatible with `security_opt: no-new-privileges:true`).
- **`notify_push` sidecar compatible:** Works seamlessly with Nextcloud `notify_push` sidecar containers overriding the entrypoint against the shared `/config` volume.

---

## Current Versions

<!-- versions:start -->
| Component | Resolved Version |
| --- | --- |
| Nextcloud | `35.0.3` |
| NGINX | `1.30.8` |
| PHP-FPM | `8.4.28` |
| Base OS | `Debian 13.8 (trixie-slim)` |
| Architectures | `linux/amd64, linux/arm64` |
| Uncompressed size (per arch) | `amd64: 534.7 MB, arm64: 1494.2 MB` |
| Last verified build (UTC) | `2026-11-28` |
| Published multi-arch digest | `dgcosenza/nextcloud@sha256:96da65456bbeaf99e1d2d66a64d0764d26881bf4b9df1b6f684d5dc0a2c7dd44` |
| GHCR mirror | `ghcr.io/dgcosenza/nextcloud@sha256:96da65456bbeaf99e1d2d66a64d0764d26881bf4b9df1b6f684d5dc0a2c7dd44` |
| Supply chain | Cosign OIDC signed + SPDX & CycloneDX SBOM attestations + SLSA Build L3 provenance |
| Security gate (Trivy + Grype on SBOM) | **0 fixable findings of any severity** (74 upstream-unfixed) |
<!-- versions:end -->

---

## Supported Tags

| Tag | Policy | Description |
| --- | --- | --- |
| `<version>-<YYYYMMDD>` (e.g. `35.0.3-20261124`) | **Immutable** | Date-stamped daily rebuild pinning the Nextcloud release and UTC build date. |
| `sha-<short>` | **Immutable** | Packaging repository Git commit tag. |
| `<version>` (e.g. `35.0.3`) | Moving | Latest verified Debian 13 security rebuild of that Nextcloud release. |
| `latest` | Moving | Latest verified build tracking the newest official Nextcloud release. |

**Production pinning:** Pin by registry digest (and review major Nextcloud upgrades before bumping):

```yaml
image: dgcosenza/nextcloud:35.0.3@sha256:<digest>
```

---

## Supported Architectures

| Architecture | Status | Verification |
| --- | --- | --- |
| `linux/amd64` | **Published & natively tested** | Built, smoke-tested, Dive-gated, Syft/Trivy/Grype-scanned, and Cosign-signed on native x86_64 CI runners. |
| `linux/arm64` | **Published & natively tested** | Built, smoke-tested, Dive-gated, Syft/Trivy/Grype-scanned, and Cosign-signed on native ARM64 CI runners. |

Identical multi-arch OCI manifest digests are published to **Docker Hub** and **GHCR** (`ghcr.io/dgcosenza/*`), accompanied by automated signed [GitHub Releases](https://github.com/dgcosenza/nextcloud-docker/releases).
---

## Quick Start

See [`docker-compose.example.yml`](https://github.com/dgcosenza/nextcloud-docker/blob/main/docker-compose.example.yml):

```bash
docker run -d \
  --name nextcloud \
  --restart unless-stopped \
  --security-opt no-new-privileges:true \
  -p 192.0.2.10:8084:443 \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Etc/UTC \
  -v "$(pwd)/config:/config" \
  -v "$(pwd)/data:/data" \
  dgcosenza/nextcloud:latest
```

---

## Configuration

### Environment Variables

| Variable | Required | Default | Description |
| --- | --- | --- | --- |
| `PUID` | No | `1000` | UID assigned to the `abc` NGINX/PHP-FPM/cron user. |
| `PGID` | No | `1000` | GID assigned to the `abc` group. |
| `TZ` | No | `Etc/UTC` | Container timezone (IANA timezone name). |
| `NEXTCLOUD_CRON_INTERVAL` | No | `300` | Seconds between `php -f /app/www/public/cron.php` runs (`0` disables the internal loop). |

### Volumes, Ports, and UID/GID

| Path / Port | Mode / Owner | Purpose |
| --- | --- | --- |
| `/config` | `PUID:PGID` (`abc`) | Persistent Nextcloud `www/nextcloud/{config,apps,themes}`, `nginx/`, `keys/`, `php/`, and `log/`. |
| `/data` | `PUID:PGID` (`abc`) | Persistent Nextcloud user file storage. |
| `80/tcp`, `443/tcp` | Container ports | HTTP and HTTPS/HTTP3 listeners. |

Run administrative commands via `docker exec nextcloud occ status`.

---

## Healthcheck

```dockerfile
HEALTHCHECK --interval=30s --timeout=10s --start-period=180s --retries=3 \
    CMD ["sh", "-c", "curl -fsSk https://127.0.0.1:443/status.php >/dev/null || exit 1"]
```

Probes Nextcloud's `/status.php` endpoint over local HTTPS.

---

## Upgrading and Migrating from `lscr.io/linuxserver/nextcloud`

1. **Always back up first:** Dump the Nextcloud database (`mariadb-dump` / `mysqldump`) and archive `./config` (and snapshot `./data`).
2. Tag your outgoing image for rollback.
3. Verify the target image's Nextcloud version is equal to or one major/minor step ahead of your installed `config.php` version (never downgrade or skip multiple major releases).
4. Pin `image: dgcosenza/nextcloud:<version>@sha256:<digest>` on `nextcloud` (and any `notify_push` sidecar sharing the image), recreate with `docker compose up -d --no-deps nextcloud notify_push`, and verify `occ status`, `/status.php`, and `notify_push` health.

---

## Supply-Chain Verification

Every published digest (multi-arch index and per-architecture manifests) on both Docker Hub and GHCR is keyless-signed with **Sigstore Cosign** (GitHub OIDC), attested with **SPDX** and **CycloneDX** SBOMs, and backed by **SLSA Build L3** provenance (`actions/attest-build-provenance`).

### Verify image signature with Cosign

```bash
cosign verify \
  --certificate-identity-regexp="^https://github\.com/dgcosenza/nextcloud-docker/\.github/workflows/daily\.yml@refs/heads/main$" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
  ghcr.io/dgcosenza/nextcloud:latest

# Or against Docker Hub (identical digest):
cosign verify \
  --certificate-identity-regexp="^https://github\.com/dgcosenza/nextcloud-docker/\.github/workflows/daily\.yml@refs/heads/main$" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
  dgcosenza/nextcloud:latest
```

### Verify SPDX / CycloneDX SBOM attestations and SLSA Build Provenance

```bash
cosign verify-attestation \
  --type spdxjson \
  --certificate-identity-regexp="^https://github\.com/dgcosenza/nextcloud-docker/\.github/workflows/daily\.yml@refs/heads/main$" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
  ghcr.io/dgcosenza/nextcloud@sha256:<arch-digest>

gh attestation verify oci://ghcr.io/dgcosenza/nextcloud:latest --owner dgcosenza
```

---

## Security

- **Vulnerability scan policy (all severities with a fix):** Every CI build runs **Trivy** (table, JSON, SARIF upload, blocking `--ignore-unfixed` gate) and **Grype** (`--only-fixed`, severity cutoff `negligible`, blocking gate), plus emits an **SPDX SBOM** (`sbom.spdx.json`) and provenance artifact.
- **Current status:** **0 fixable vulnerabilities of any severity** across Debian 13 OS packages, PHP 8.4, NGINX 1.30, and Nextcloud.
- **Bundled PHP dependencies:** The official Nextcloud release ships a `3rdparty` Composer bundle. At build time the vulnerable bundled packages are patched to their published fixed versions: `symfony/filesystem` and `symfony/http-foundation` to `v7.4.23`, `symfony/routing` to `v6.4.50`, and `web-auth/webauthn-lib` to a patched build carrying the upstream `5.3.5` fix for `GHSA-gq4g-fpc9-vjfq`. The webauthn patch preserves the 4.x API that Nextcloud 35 uses (upstream 5.x removed classes that Nextcloud calls), and is applied with a checksum-pinned Composer build so the all-severity gates stay green without changing the application's behaviour.
- **Hardening:** `tini` PID 1, `no-new-privileges:true` compatible via `setpriv`, workers and background cron run as non-root `abc`, compilers excluded from runtime layer, built-in Nextcloud self-updater removed.
- See [`SECURITY.md`](https://github.com/dgcosenza/nextcloud-docker/blob/main/SECURITY.md).

---

## Build Locally

```bash
git clone https://github.com/dgcosenza/nextcloud-docker.git
cd nextcloud-docker

docker buildx build \
  --platform linux/amd64 \
  --load \
  --build-arg BUILD_DATE="$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --build-arg IMAGE_REVISION="$(git rev-parse HEAD)" \
  -t dgcosenza/nextcloud:local \
  .
```

| Build Arg | Default | Purpose |
| --- | --- | --- |
| `NEXTCLOUD_VERSION` | `35.0.3` | Official Nextcloud release version (SHA-256 verified, overridden daily by CI). |
| `NGINX_VERSION` | `1.30.8` | Official stable NGINX release from `nginx.org` (overridden daily by CI). |
| `NGX_BROTLI_COMMIT` | `53e0fb55f250f48fe80c0ddbf6c0f7103cdbaae1` | Pinned `google/ngx_brotli` commit SHA. |
| `DEBIAN_BASE` | `debian:trixie-slim` | Base OS image. |

---

## Update Policy

[`.github/workflows/daily.yml`](https://github.com/dgcosenza/nextcloud-docker/blob/main/.github/workflows/daily.yml) runs automatically every day at **04:53 UTC**, on pushes to `main`, on pull requests (verification only), and via `workflow_dispatch`. Every scheduled run executes a seven-step automated pipeline (gated by `.github/workflows/public-check.yml`):

1. **Upstream check:** Queries `nextcloud/server` latest stable release via the authenticated GitHub API, resolves latest stable NGINX from `nginx.org` and the `debian:trixie-slim` base digest, diffs against `versions.json`, and emits `upstream-changes.md`.
2. **No-cache rebuild:** Rebuilds `linux/amd64` with `--no-cache` on schedule, verifies the Nextcloud tarball SHA-256, compiles NGINX + `ngx_brotli`, upgrades Debian 13 + PHP 8.4 packages, and emits an **SPDX SBOM** (`sbom.spdx.json`) and provenance artifact.
3. **Vulnerability fix and gate:** Runs **Trivy** (table, JSON, SARIF upload, blocking `--ignore-unfixed` gate) and **Grype** (blocking `--only-fixed` gate, severity cutoff `negligible`), diffs findings against the previous scan, and retains reports for 90 days.
4. **Smoke test:** Runs [`tests/smoke.sh`](https://github.com/dgcosenza/nextcloud-docker/blob/main/tests/smoke.sh) to verify fresh Nextcloud hydration, `tini` PID 1, non-root `abc` NGINX & PHP 8.4 FPM workers, HTTPS `/status.php`, `occ status`, and a negative closed-port healthcheck test.
5. **Publish:** On non-PR builds when Docker Hub secrets are configured, pushes `latest`, `<version>`, `<version>-<YYYYMMDD>`, and `sha-<short>` tags to Docker Hub and records the immutable digest.
6. **Automated documentation sync:** Commits updated `versions.json`, the README `Current Versions` block, and a dated `CHANGELOG.md` entry via `github-actions[bot]` with `[skip ci]` when content changes, then syncs the Docker Hub overview via `peter-evans/dockerhub-description`.
7. **Failure alerting:** On failure, CI opens or updates a single GitHub issue labeled `ci-failure` with the failing job and run link, and auto-closes it on the next green run.

---

## Design Decisions

- **Debian 13 (`trixie-slim`) + PHP 8.4 + source-built NGINX 1.30:** Nextcloud 35 officially supports PHP 8.3–8.5; Debian 13's PHP 8.4 receives daily Debian Security patches, while source-built NGINX 1.30 provides HTTP/3 QUIC and dynamically linked `ngx_brotli`.
- **In-process cron loop via `setpriv`:** Runs `cron.php` every 5 minutes as UID/GID `PUID:PGID` without requiring root `crond` or disabling `no-new-privileges:true`.

---

## License

This repository follows a clear packaging-vs-upstream license split:

- **Container packaging, scripts, CI workflows, and documentation (`packaging: MIT`):** Licensed under the [MIT License](https://github.com/dgcosenza/nextcloud-docker/blob/main/LICENSE) — copyright **Daniel G. Cosenza from FNX Labs**.
- **Bundled upstream software — Nextcloud Server (`nextcloud/server`) (`upstream: AGPL-3.0-or-later`):** Nextcloud Server is licensed under the [GNU Affero General Public License v3.0 or later (`AGPL-3.0-or-later`)](https://github.com/nextcloud/server/blob/master/COPYING). Bundled NGINX and `ngx_brotli` are BSD-2-Clause; PHP 8.4 is PHP-3.01.

Full third-party notices are maintained in [`THIRD-PARTY-NOTICES.md`](https://github.com/dgcosenza/nextcloud-docker/blob/main/THIRD-PARTY-NOTICES.md). Release history is maintained in [`CHANGELOG.md`](https://github.com/dgcosenza/nextcloud-docker/blob/main/CHANGELOG.md).
