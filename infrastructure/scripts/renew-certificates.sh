#!/usr/bin/env sh
set -eu

: "${DESEC_CREDENTIALS_FILE:?Define the root-owned external deSEC credential file path}"

compose() {
  docker compose \
    -f compose.yaml \
    -f compose.tls.yaml \
    --profile tls \
    "$@"
}

marker=/etc/letsencrypt/.nginx-reload-required

compose run --rm certbot renew \
  --deploy-hook "touch ${marker}"

if compose run --rm --entrypoint /bin/sh certbot -c "test -f ${marker}"; then
  compose exec -T nginx nginx -t
  compose exec -T nginx nginx -s reload
  compose run --rm --entrypoint /bin/sh certbot -c "rm -f ${marker}"
fi
