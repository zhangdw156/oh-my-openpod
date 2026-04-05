#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

help_output="$(bash "${repo_root}/install/bootstrap.sh" --help)"

printf '%s' "${help_output}" | rg -q -- '--flavor' || fail "bootstrap help missing --flavor"
for flavor in openpod claudepod codexpod; do
  printf '%s' "${help_output}" | rg -q -- "${flavor}" || fail "bootstrap help missing flavor ${flavor}"
done
