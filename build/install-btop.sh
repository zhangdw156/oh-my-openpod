#!/usr/bin/env bash
set -euo pipefail

target_arch="${TARGETARCH:-}"
version="v1.4.6"
asset_dir="/opt/vendor/releases/btop/${version}"

if [[ -z "${target_arch}" ]]; then
  target_arch="$(dpkg --print-architecture)"
fi

case "${target_arch}" in
  amd64|x86_64)
    btop_arch="x86_64"
    ;;
  arm64|aarch64)
    btop_arch="aarch64"
    ;;
  *)
    echo "Unsupported architecture for btop: ${target_arch}" >&2
    exit 1
    ;;
esac

archive_name="btop-${btop_arch}-unknown-linux-musl.tbz"
archive_path="${asset_dir}/${archive_name}"
checksum_file="${asset_dir}/SHA256SUMS"

tmp_dir="$(mktemp -d)"
cleanup() {
  rm -rf "${tmp_dir}"
}
trap cleanup EXIT

expected_sha="$(awk -v name="${archive_name}" '$2 == name {print $1}' "${checksum_file}")"
actual_sha="$(sha256sum "${archive_path}" | awk '{print $1}')"

if [[ -z "${expected_sha}" || "${actual_sha}" != "${expected_sha}" ]]; then
  echo "Checksum mismatch for btop ${version} (${btop_arch})" >&2
  echo "Expected: ${expected_sha:-missing}" >&2
  echo "Actual:   ${actual_sha}" >&2
  exit 1
fi

tar -xjf "${archive_path}" -C "${tmp_dir}"

rm -rf /opt/btop
mv "${tmp_dir}/btop" /opt/btop
ln -sf /opt/btop/bin/btop /usr/local/bin/btop

test -x /usr/local/bin/btop
