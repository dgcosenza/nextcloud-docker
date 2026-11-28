# Changelog

All notable changes to the `dgcosenza/nextcloud` Debian 13 container packaging and CI workflows are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Maintained by **Daniel G. Cosenza from FNX Labs**.

## [Unreleased] — 2026-11-26

### Fixed
- Restored the Daily build to green by patching the bundled Nextcloud `3rdparty` Composer packages that the all-severity vulnerability gate correctly flagged: `symfony/filesystem` and `symfony/http-foundation` to `v7.4.23`, `symfony/routing` to `v6.4.50`, and `web-auth/webauthn-lib` to a patched build with the upstream `5.3.5` fix for `GHSA-gq4g-fpc9-vjfq` (4.x API preserved for Nextcloud compatibility). No scan gate was weakened.

---
<!-- changelog:auto -->

## [35.0.3] — 2026-11-28

### Automated Daily Build
- Verified components: Nextcloud `35.0.3`, NGINX `1.30.8`, PHP-FPM `8.4.28`, Base OS `Debian 13.8 (trixie-slim)`.
- Architectures verified: `linux/amd64, linux/arm64` (native smoke tests + Dive efficiency gate).
- Upstream status: no new upstream release since previous build; refreshed base OS and dependencies.
- Vulnerability gate: **0 fixable findings of any severity** in Trivy and Grype (SBOM scan) (74 upstream-unfixed).
- Published multi-arch digest (Docker Hub + GHCR): `dgcosenza/nextcloud@sha256:96da65456bbeaf99e1d2d66a64d0764d26881bf4b9df1b6f684d5dc0a2c7dd44` (Cosign OIDC signed + SPDX/CycloneDX SBOM + SLSA L3 provenance).

---

## [35.0.3] — 2026-11-27

### Automated Daily Build
- Verified components: Nextcloud `35.0.3`, NGINX `1.30.8`, PHP-FPM `8.4.28`, Base OS `Debian 13.8 (trixie-slim)`.
- Architectures verified: `linux/amd64, linux/arm64` (native smoke tests + Dive efficiency gate).
- Upstream status: no new upstream release since previous build; refreshed base OS and dependencies.
- Vulnerability gate: **0 fixable findings of any severity** in Trivy and Grype (SBOM scan) (74 upstream-unfixed).
- Published multi-arch digest (Docker Hub + GHCR): `dgcosenza/nextcloud@sha256:628f01326645cd8c7962d2190efaa975a095696bdfaa27090eeaff78509e9981` (Cosign OIDC signed + SPDX/CycloneDX SBOM + SLSA L3 provenance).
---

## [35.0.3] — 2026-11-26

### Automated Daily Build
- Verified components: Nextcloud `35.0.3`, NGINX `1.30.8`, PHP-FPM `8.4.28`, Base OS `Debian 13.8 (trixie-slim)`.
- Architectures verified: `linux/amd64, linux/arm64` (native smoke tests + Dive efficiency gate).
- Upstream status: no new upstream release since previous build; refreshed base OS and dependencies.
- Vulnerability gate: **0 fixable findings of any severity** in Trivy and Grype (SBOM scan) (74 upstream-unfixed).
- Published multi-arch digest (Docker Hub + GHCR): `dgcosenza/nextcloud@sha256:355845be275d91cfaf25cd799a3415553210888484dc69299a532559b579ca4f` (Cosign OIDC signed + SPDX/CycloneDX SBOM + SLSA L3 provenance).
---

## [35.0.3] — 2026-11-25

### Automated Daily Build
- Verified components: Nextcloud `35.0.3`, NGINX `1.30.8`, PHP-FPM `8.4.28`, Base OS `Debian 13.8 (trixie-slim)`.
- Architectures verified: `linux/amd64, linux/arm64` (native smoke tests + Dive efficiency gate).
- Upstream status: no new upstream release since previous build; refreshed base OS and dependencies.
- Vulnerability gate: **0 fixable Critical/High** in Trivy and Grype (SBOM scan) (72 upstream-unfixed).
- Published multi-arch digest (Docker Hub + GHCR): `dgcosenza/nextcloud@sha256:a9ebb6eec412203c0ecb929ffa3e064b2cf24f4fb730e6b7026b0d8d46b6385a` (Cosign OIDC signed + SPDX/CycloneDX SBOM + SLSA L3 provenance).
---

## [35.0.3] — 2026-11-24

### Added
- Initial **Debian 13 (`trixie-slim`)** image for **Nextcloud 35.0.3** (SHA-256 verified) with source-built **NGINX 1.30.8** (HTTP/3 QUIC + dynamically linked `ngx_brotli`) and **PHP 8.4 FPM**.
- Full drop-in `/config` and `/data` layout compatibility (`PUID`/`PGID` user `abc`, `/app/www/public` symlinks, `occ` CLI helper, non-root `cron.php` loop, downgrade protection, and `notify_push` sidecar compatibility).
- Seven-step automated daily CI pipeline (`.github/workflows/daily.yml`) with Trivy and Grype fixable Critical/High blocking gates, Syft SPDX SBOM, smoke test (`tests/smoke.sh`), automated docs/Hub sync, and `ci-failure` issue alerting.
