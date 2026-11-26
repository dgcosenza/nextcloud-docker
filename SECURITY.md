# Security Policy

Maintained by **Daniel G. Cosenza from FNX Labs**.

## Supported Versions

Only the latest daily build of `dgcosenza/nextcloud` packaging the latest official Nextcloud release with source-built NGINX 1.30 and Debian 13 PHP 8.4 FPM is actively maintained and receives automated security rebuilds.

## Automated Vulnerability Scanning

Every build in GitHub Actions enforces:
- Official SHA-256 verification of the Nextcloud release archive from `download.nextcloud.com`.
- **Trivy** (`--ignore-unfixed`, all severities `UNKNOWN,LOW,MEDIUM,HIGH,CRITICAL`) blocking gate + table/JSON reports + SARIF upload to GitHub Code Scanning.
- **Grype** (`--only-fixed --fail-on negligible`, all severities) blocking gate + persisted report artifact.
- **Syft** SPDX SBOM (`sbom.spdx.json`) and build provenance artifacts.

## Reporting a Vulnerability

- **Container packaging or CI issues:** Open a private security advisory via GitHub Security Advisories on [`dgcosenza/nextcloud-docker`](https://github.com/dgcosenza/nextcloud-docker/security/advisories/new).
- **Upstream Nextcloud issues:** Report via Nextcloud's security program at [nextcloud.com/security](https://nextcloud.com/security/).
