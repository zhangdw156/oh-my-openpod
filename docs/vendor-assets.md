# Vendored Build Assets

## Purpose

This repository keeps shared build-time assets under `vendor/` so the common `devpod` base stays reproducible across all runtime flavors.

Shared vendored assets include:

- release archives for `antidote`, `btop`, `neovim`, `zellij`, and `yazi`
- Zsh plugin snapshots
- LazyVim starter snapshot
- OpenCode-specific upstream snapshot currently reused by the `openpod` flavor and as the source of vendored `superpowers` skills for other flavors

The machine-readable inventory lives in [`vendor/manifest.lock.json`](../vendor/manifest.lock.json).

## Shared Vendor Layout

```text
vendor/
├── manifest.lock.json
├── nvim/
│   └── lazyvim-starter/
├── opencode/
│   ├── packages/
│   │   └── superpowers/
│   └── skills/
├── releases/
│   ├── antidote/
│   ├── btop/
│   ├── neovim/
│   ├── yazi/
│   └── zellij/
└── zsh/
    ├── ohmyzsh/
    ├── powerlevel10k/
    ├── zsh-autosuggestions/
    ├── zsh-history-substring-search/
    └── zsh-syntax-highlighting/
```

Flavor-specific runtime assets live outside `vendor/` under:

- `runtime/openpod/`
- `runtime/claudepod/`
- `runtime/codexpod/`

## Shared Release Assets

| Component | Version | Local path |
|-----------|---------|------------|
| Antidote | `v2.0.10` | `vendor/releases/antidote/v2.0.10/` |
| btop | `v1.4.6` | `vendor/releases/btop/v1.4.6/` |
| Neovim | `v0.12.0` | `vendor/releases/neovim/v0.12.0/` |
| Zellij | `v0.44.0` | `vendor/releases/zellij/v0.44.0/` |
| Yazi | `v26.1.22` | `vendor/releases/yazi/v26.1.22/` |

Each release directory includes a `SHA256SUMS` file. The shared install scripts in `build/` verify these local assets before extracting or installing them.

## Flavor-Specific Skill Materialization

Current runtime wiring uses the shared OpenCode `superpowers` snapshot as the source for:

- `runtime/claudepod/skills/superpowers/`
- `runtime/codexpod/skills/superpowers/`

`build/update-vendor-assets.sh` refreshes those flavor-owned skills trees after updating the upstream vendored snapshot.

## Update Workflow

Use:

```bash
bash build/update-vendor-assets.sh
```

After running it:

1. Review changes under `vendor/`
2. Review synchronized flavor skills under `runtime/claudepod/skills/` and `runtime/codexpod/skills/`
3. Update [`vendor/manifest.lock.json`](../vendor/manifest.lock.json) if versions or sources changed
4. Rebuild the base and flavors:

```bash
docker compose build devpod openpod claudepod codexpod
```

## Notes

- Shared assets stay in `vendor/`; harness-specific runtime assets stay in `runtime/<flavor>/`
- This project intentionally avoids Git submodules
- Local builds still need network access to base image registries and any harness installer endpoints that are not vendored
