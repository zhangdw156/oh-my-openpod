#!/usr/bin/env bash
set -euo pipefail

version="v2.0.10"
asset_dir="/opt/vendor/releases/antidote/${version}"
archive_name="antidote-${version}.tar.gz"
archive_path="${asset_dir}/${archive_name}"
checksum_file="${asset_dir}/SHA256SUMS"

expected_sha="$(awk -v name="${archive_name}" '$2 == name {print $1}' "${checksum_file}")"
actual_sha="$(sha256sum "${archive_path}" | awk '{print $1}')"

if [[ -z "${expected_sha}" || "${actual_sha}" != "${expected_sha}" ]]; then
  echo "Checksum mismatch for antidote ${version}" >&2
  echo "Expected: ${expected_sha:-missing}" >&2
  echo "Actual:   ${actual_sha}" >&2
  exit 1
fi

rm -rf /opt/antidote
mkdir -p /opt/antidote
tar -xzf "${archive_path}" --strip-components=1 -C /opt/antidote

test -f /opt/antidote/antidote.zsh
