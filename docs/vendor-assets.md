# Vendored Build Assets

## Purpose

This project keeps the first batch of build-time release assets and Zsh plugin sources under `vendor/` so local image builds stay fast and predictable.

- No GitHub release download is required for `antidote`, `btop`, `zellij`, or `yazi`
- No plugin repository clone is required for the default Zsh setup
- Users do not need Git submodules or `git clone --recursive`

The machine-readable inventory lives in [`vendor/manifest.lock.json`](../vendor/manifest.lock.json).

## Directory Layout

```text
vendor/
├── manifest.lock.json
├── releases/
│   ├── antidote/
│   ├── btop/
│   ├── yazi/
│   └── zellij/
└── zsh/
    ├── ohmyzsh/
    ├── powerlevel10k/
    ├── zsh-autosuggestions/
    ├── zsh-history-substring-search/
    └── zsh-syntax-highlighting/
```

## Vendored Release Assets

| Component | Version | Local path | Upstream source |
|-----------|---------|------------|-----------------|
| Antidote | `v2.0.10` | `vendor/releases/antidote/v2.0.10/` | `mattmc3/antidote` tag archive |
| btop | `v1.4.6` | `vendor/releases/btop/v1.4.6/` | `aristocratos/btop` release assets |
| Zellij | `v0.44.0` | `vendor/releases/zellij/v0.44.0/` | `zellij-org/zellij` release assets |
| Yazi | `v26.1.22` | `vendor/releases/yazi/v26.1.22/` | `sxyazi/yazi` Debian packages |

Each release directory includes a `SHA256SUMS` file. The `build/install-*.sh` scripts verify the local asset before extracting or installing it.

## Vendored Zsh Plugins

| Component | Source | Local path |
|-----------|--------|------------|
| oh-my-zsh | `ohmyzsh/ohmyzsh@9e2c1548c3dfeefd055e1c6606f66657093ae928` | `vendor/zsh/ohmyzsh/` |
| Powerlevel10k | `romkatv/powerlevel10k@604f19a9eaa18e76db2e60b8d446d5f879065f90` | `vendor/zsh/powerlevel10k/` |
| zsh-autosuggestions | `zsh-users/zsh-autosuggestions@85919cd1ffa7d2d5412f6d3fe437ebdbeeec4fc5` | `vendor/zsh/zsh-autosuggestions/` |
| zsh-history-substring-search | `zsh-users/zsh-history-substring-search@14c8d2e0ffaee98f2df9850b19944f32546fdea5` | `vendor/zsh/zsh-history-substring-search/` |
| zsh-syntax-highlighting | `zsh-users/zsh-syntax-highlighting@1d85c692615a25fe2293bdd44b34c217d5d2bf04` | `vendor/zsh/zsh-syntax-highlighting/` |

The default shell setup now sources these local copies directly from `/opt/vendor/zsh` inside the image.

## Update Workflow

Use the helper script below whenever you want to refresh the vendored assets:

```bash
bash build/update-vendor-assets.sh
```

After running it:

1. Review the new files under `vendor/`
2. Update [`vendor/manifest.lock.json`](../vendor/manifest.lock.json) if versions or commits changed
3. Rebuild the image with `docker compose up -d --build`
4. Verify the container starts cleanly and the vendored Zsh plugins still load correctly

## Notes

- This approach intentionally avoids Git submodules.
- Local builds still need access to base image registries such as Docker Hub and GHCR.
- The vendored assets are part of the repository history, so version bumps should stay deliberate and infrequent.
