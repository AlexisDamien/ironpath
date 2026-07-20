#!/usr/bin/env bash
set -euo pipefail

API_URL="${API_URL:-http://localhost:8080}"
MAILPIT_URL="${MAILPIT_URL:-http://localhost:8025}"
SMOKE_EMAIL="docker-smoke-${GITHUB_RUN_ID:-local}-$(date +%s)@example.test"

printf 'Vérification de la santé du backend...\n'
health="$(curl --fail --silent --show-error --retry 12 --retry-delay 2 \
  --retry-all-errors "$API_URL/actuator/health")"
printf '%s\n' "$health"
grep -q '"status":"UP"' <<<"$health"

printf 'Vérification de Mailpit...\n'
curl --fail --silent --show-error --retry 12 --retry-delay 2 \
  --retry-all-errors "$MAILPIT_URL/readyz" >/dev/null

printf 'Création du compte de smoke test %s...\n' "$SMOKE_EMAIL"
status="$(curl --silent --show-error \
  --output /tmp/ironpath-register-response.json \
  --write-out '%{http_code}' \
  --header 'Content-Type: application/json' \
  --request POST \
  --data "{\"email\":\"$SMOKE_EMAIL\",\"password\":\"IronPath!2026#\",\"rgpdConsent\":true}" \
  "$API_URL/api/auth/register")"

if [[ "$status" != "201" ]]; then
  printf 'Inscription refusée, HTTP %s :\n' "$status" >&2
  cat /tmp/ironpath-register-response.json >&2
  exit 1
fi

printf 'Vérification de la réception de l’email de confirmation...\n'
for attempt in $(seq 1 15); do
  if curl --fail --silent --show-error \
    "$MAILPIT_URL/view/latest.html?query=to:${SMOKE_EMAIL}" \
    | grep -q 'Confirmez votre adresse email'; then
    printf 'Smoke test Docker réussi.\n'
    exit 0
  fi

  printf 'Email pas encore visible (%s/15), nouvelle tentative...\n' "$attempt"
  sleep 2
done

printf 'Aucun email de confirmation reçu par Mailpit.\n' >&2
exit 1
