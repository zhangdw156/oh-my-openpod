#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp_out="$(mktemp)"
trap 'rm -f "${tmp_out}"' EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

docker compose -f "${repo_root}/docker-compose.yml" config > "${tmp_out}"

for service in openpod claudepod codexpod; do
  if ! rg -q "^  ${service}:" "${tmp_out}"; then
    fail "missing compose service: ${service}"
  fi
done

for dockerfile in \
  "dockerfile: docker/openpod/Dockerfile" \
  "dockerfile: docker/claudepod/Dockerfile" \
  "dockerfile: docker/codexpod/Dockerfile"; do
  if ! rg -q "${dockerfile}" "${tmp_out}"; then
    fail "missing compose dockerfile path: ${dockerfile}"
  fi
done
