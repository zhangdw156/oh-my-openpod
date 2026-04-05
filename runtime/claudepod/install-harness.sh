#!/usr/bin/env bash
set -euo pipefail

repo_root="${OPENPOD_REPO_ROOT:?missing OPENPOD_REPO_ROOT}"
bin_dir="${OPENPOD_BIN_DIR:?missing OPENPOD_BIN_DIR}"
config_home="${OPENPOD_CONFIG_HOME:?missing OPENPOD_CONFIG_HOME}"

mkdir -p "${config_home}"
export OPENPOD_BIN_DIR="${bin_dir}"
export OPENPOD_CLAUDE_INSTALL_HOME="${HOME}"
export OPENPOD_CLAUDE_CODE_VERSION="${OPENPOD_CLAUDE_CODE_VERSION:-2.1.92}"

bash "${repo_root}/build/install-claude-code.sh"

if [[ -d "${repo_root}/runtime/claudepod/skills" ]]; then
  ln -sfn "${repo_root}/runtime/claudepod/skills" "${config_home}/skills"
fi

install -m 0755 "${repo_root}/runtime/claudepod/bin/claude" "${bin_dir}/claude"
install -m 0755 "${repo_root}/runtime/claudepod/bin/claudepod-shell" "${bin_dir}/claudepod-shell"
