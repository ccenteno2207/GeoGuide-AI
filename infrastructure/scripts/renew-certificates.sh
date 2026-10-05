#!/usr/bin/env sh
set -eu

: "${DESEC_CREDENTIALS_FILE:?Define the root-owned external deSEC credential file path}"

renew_compose() {
  docker compose -f compose.renew.yaml "$@"
}

nginx_container() {
  containers="$(docker ps --quiet \
    --filter label=com.docker.compose.project=geoguide-ai \
    --filter label=com.docker.compose.service=nginx)"
  count="$(printf '%s\n' "$containers" | sed '/^$/d' | wc -l)"

  if [ "$count" -ne 1 ]; then
    echo "Expected exactly one running GeoGuide Nginx container; found $count." >&2
    exit 1
  fi

  printf '%s\n' "$containers"
}

marker=/etc/letsencrypt/.nginx-reload-required

renew_compose run --rm certbot renew \
  --deploy-hook "touch ${marker}"

if renew_compose run --rm --entrypoint /bin/sh certbot -c "test -f ${marker}"; then
  nginx="$(nginx_container)"
  docker exec "$nginx" nginx -t
  docker exec "$nginx" nginx -s reload
  renew_compose run --rm --entrypoint /bin/sh certbot -c "rm -f ${marker}"
fi
