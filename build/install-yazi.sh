#!/usr/bin/env bash
set -euo pipefail

target_arch="${TARGETARCH:-}"
version="v26.1.22"
asset_dir="/opt/vendor/releases/yazi/${version}"

if [[ -z "${target_arch}" ]]; then
  target_arch="$(dpkg --print-architecture)"
fi

case "${target_arch}" in
  amd64|x86_64)
    yazi_arch="x86_64"
    ;;
  arm64|aarch64)
    yazi_arch="aarch64"
    ;;
  *)
    echo "Unsupported architecture for yazi: ${target_arch}" >&2
    exit 1
    ;;
esac

asset_name="yazi-${yazi_arch}-unknown-linux-gnu.deb"
asset_path="${asset_dir}/${asset_name}"
checksum_file="${asset_dir}/SHA256SUMS"

tmp_dir="$(mktemp -d)"
cleanup() {
  rm -rf "${tmp_dir}"
}
trap cleanup EXIT

expected_sha="$(awk -v name="${asset_name}" '$2 == name {print $1}' "${checksum_file}")"
actual_sha="$(sha256sum "${asset_path}" | awk '{print $1}')"

if [[ -z "${expected_sha}" || "${actual_sha}" != "${expected_sha}" ]]; then
  echo "Checksum mismatch for yazi ${version} (${yazi_arch})" >&2
  echo "Expected: ${expected_sha:-missing}" >&2
  echo "Actual:   ${actual_sha}" >&2
  exit 1
fi

# Extract the upstream package payload directly so we can keep Yazi's
# core navigation binaries without pulling in every optional preview helper.
dpkg-deb -x "${asset_path}" /

test -x /usr/bin/yazi
test -x /usr/bin/ya
