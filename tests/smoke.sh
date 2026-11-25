#!/usr/bin/env bash
# Smoke test for dgcosenza/nextcloud: verifies fresh Nextcloud hydration,
# tini PID 1, non-root abc workers, HTTPS /status.php JSON response,
# occ status command, and negative closed-port healthcheck.
set -euo pipefail

IMAGE="${1:-dgcosenza/nextcloud:ci-candidate}"
NAME="nextcloud-ci-smoke-$$"
TMPCONF="$(mktemp -d)"
TMPDATA="$(mktemp -d)"
chmod 777 "$TMPCONF" "$TMPDATA"

cleanup() {
  docker rm -f "$NAME" >/dev/null 2>&1 || true
  docker run --rm --user 0:0 -v "${TMPCONF}:/c" -v "${TMPDATA}:/d" --entrypoint /bin/sh "$IMAGE" -c 'rm -rf /c/* /c/.[!.]* /d/* /d/.[!.]*' >/dev/null 2>&1 || true
  rm -rf "$TMPCONF" "$TMPDATA" 2>/dev/null || true
}
trap cleanup EXIT

docker run -d --name "$NAME" \
  --security-opt no-new-privileges:true \
  -p 127.0.0.1:18444:443 \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Etc/UTC \
  -v "${TMPCONF}:/config" \
  -v "${TMPDATA}:/data" \
  "$IMAGE"

# Wait for /status.php to return valid Nextcloud JSON
READY=0
for _ in $(seq 1 60); do
  if ! docker ps -q --filter "name=^/${NAME}$" | grep -q .; then
    echo "ERROR: nextcloud container exited prematurely:" >&2
    docker logs "$NAME" >&2 || true
    exit 1
  fi
  STATUS_JSON="$(docker exec "$NAME" curl -fsSk --max-time 5 https://127.0.0.1:443/status.php 2>/dev/null || true)"
  if printf '%s' "$STATUS_JSON" | grep -q '"productname":"Nextcloud"'; then
    READY=1
    break
  fi
  sleep 2
done
if [ "$READY" -ne 1 ]; then
  echo "ERROR: Nextcloud /status.php did not respond within timeout." >&2
  docker logs "$NAME" >&2 || true
  exit 1
fi
echo "status.php: ${STATUS_JSON}"

# Verify tini PID 1 and non-root abc workers
PID1_COMM="$(docker exec "$NAME" cat /proc/1/comm)"
test "$PID1_COMM" = "tini"
docker exec "$NAME" ps -eo user,comm | grep -qE '^abc[[:space:]]+nginx$'
docker exec "$NAME" ps -eo user,comm | grep -qE '^abc[[:space:]]+php-fpm8\.4$'

# Verify occ helper runs cleanly as non-root abc
OCC_OUT="$(docker exec "$NAME" occ status)"
echo "occ status: ${OCC_OUT}"
printf '%s' "$OCC_OUT" | grep -q 'installed:'

# Run exact healthcheck and negative closed-port check
docker exec "$NAME" sh -c "curl -fsSk https://127.0.0.1:443/status.php >/dev/null"
if docker exec "$NAME" sh -c "curl -fsSk --max-time 3 https://127.0.0.1:59999/status.php >/dev/null 2>&1"; then
  echo "ERROR: healthcheck unexpectedly passed on closed port 59999" >&2
  exit 1
fi

echo "Smoke test passed (pid1=${PID1_COMM}, status.php=ok, occ=ok)."
