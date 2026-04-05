# Multi-Flavor `devpod` Design

## Summary

This design replaces the current branch-per-harness model with a single `main` branch that produces multiple runtime flavors from one shared base.

The repository will converge on:

- one shared base image and bootstrap foundation: `devpod`
- multiple thin harness flavors built on top of it:
  - `openpod`
  - `claudepod`
  - `codexpod`

The shared base owns the common developer environment:

- Ubuntu base image
- Zsh and vendored shell plugins
- Neovim and LazyVim defaults
- uv and Python dev tooling
- zellij, btop, yazi, git, ripgrep, fd, and other common CLI tools

Each flavor differs only in:

- which harness is installed
- which harness-specific configuration is provided
- which harness-specific skills are preinstalled

Everything else must stay shared.

## Goals

- Return to a single long-lived `main` branch
- Eliminate branch-per-harness maintenance
- Introduce a shared `devpod` base for common tooling and environment setup
- Support multiple published images from the same repository state
- Keep harness differences isolated to thin flavor-specific layers
- Reuse the same flavor model for both Docker and bootstrap flows

## Non-Goals

- Changing the core shared tool stack
- Mixing harness-specific logic into the shared base layer
- Creating a fourth public `devpod` product image in the first pass
- Replacing harness-native configuration models with a unified auth layer

## Current Problem

The repository currently has runtime-specific logic bound directly into:

- `Dockerfile`
- `docker-compose.yml`
- `install/bootstrap.sh`
- runtime config layout
- vendor layout
- documentation

This was manageable with one runtime, and tolerable with a temporary branch split, but it does not scale cleanly to multiple harnesses.

If the project keeps adding long-lived branches like `dev/claude` and later a Codex branch, maintenance cost will grow across:

- duplicated Dockerfiles
- duplicated bootstrap logic
- duplicated docs
- duplicated release flows
- harder backports of shared environment improvements

The underlying issue is architectural: the repository currently treats the harness and the developer environment as one inseparable product.

## Recommended Architecture

Use a shared-base plus thin-flavor model.

### Shared Base

Create a single shared base image/build foundation:

- `devpod`

This base owns all common developer-environment concerns and must remain harness-agnostic.

### Flavor Images

Create thin flavor layers on top of the base:

- `openpod`
- `claudepod`
- `codexpod`

Each flavor adds only:

- harness installation
- harness launcher/wrapper
- harness-specific default config
- harness-specific skills

## Approaches Considered

### Approach 1: Keep Separate Long-Lived Branches

Pros:

- each branch can evolve independently
- easiest short-term adaptation when adding a new harness

Cons:

- duplicated maintenance
- shared fixes must be cherry-picked repeatedly
- release/documentation drift becomes likely
- scales poorly beyond two harnesses

### Approach 2: Single Branch With Many Inline Conditionals

Pros:

- one branch
- minimal file proliferation

Cons:

- shared scripts become full of flavor-specific branching
- harder to read and review
- weak boundaries between shared logic and harness logic

### Approach 3: Single Branch With Shared Base And Thin Flavor Layers

Pros:

- one branch
- clean separation of concerns
- good reuse of shared tooling
- easy to add future harnesses
- easier review and testing

Cons:

- requires up-front refactoring
- needs strict discipline to keep flavor logic out of the base

### Recommendation

Use Approach 3.

## Repository Layout

Use one shared base Dockerfile plus one Dockerfile per flavor.

Recommended top-level layout:

```text
oh-my-openpod/
├── Dockerfile.devpod
├── Dockerfile.openpod
├── Dockerfile.claudepod
├── Dockerfile.codexpod
├── docker-compose.yml
├── install/
│   └── bootstrap.sh
├── runtime/
│   ├── openpod/
│   │   ├── bin/
│   │   ├── config/
│   │   ├── install-harness.sh
│   │   └── skills/
│   ├── claudepod/
│   │   ├── bin/
│   │   ├── config/
│   │   ├── install-harness.sh
│   │   └── skills/
│   └── codexpod/
│       ├── bin/
│       ├── config/
│       ├── install-harness.sh
│       └── skills/
├── build/
├── config/
│   ├── nvim/
│   ├── .zshrc
│   └── .p10k.zsh
└── vendor/
    ├── releases/
    ├── zsh/
    └── nvim/
```

## Shared Base Responsibilities

`Dockerfile.devpod` and shared bootstrap logic own:

- base OS packages
- common shell environment
- shared terminal tooling
- shared editor tooling
- shared Python tooling
- common filesystem layout
- shared vendor asset installation

The shared base must not:

- install any specific harness
- reference harness-specific config directories
- reference harness-specific skills
- reference harness-specific auth models

## Flavor Responsibilities

Each flavor under `runtime/<flavor>/` owns:

- harness installation script
- flavor-specific launcher or wrapper
- flavor-specific config files
- flavor-specific preinstalled skills

Each flavor must not:

- reinstall shared base tools
- duplicate common shell/editor/tooling setup
- modify unrelated flavors

## Docker Model

### Dockerfiles

Use:

- `Dockerfile.devpod` for the shared base
- `Dockerfile.openpod` for OpenCode flavor
- `Dockerfile.claudepod` for Claude Code flavor
- `Dockerfile.codexpod` for Codex flavor

`Dockerfile.<flavor>` should be thin wrappers over the shared base, ideally with the majority of the file dedicated to:

- copying `runtime/<flavor>/...`
- running `runtime/<flavor>/install-harness.sh`
- wiring the flavor launcher/config/skills

### Compose

Use one `docker-compose.yml` with multiple services:

- `openpod`
- `claudepod`
- `codexpod`

Each service should:

- build from its own Dockerfile
- publish a distinct image name
- share the same workspace-mount pattern

## Image Naming

Publish three public image families:

- `oh-my-openpod:*`
- `oh-my-claudepod:*`
- `oh-my-codexpod:*`

Use the same release version across all three for a given release cut.

Example:

- `ghcr.io/zhangdw156/oh-my-openpod:0.5.0`
- `ghcr.io/zhangdw156/oh-my-claudepod:0.5.0`
- `ghcr.io/zhangdw156/oh-my-codexpod:0.5.0`

## Bootstrap Model

Keep a single bootstrap entrypoint:

- `install/bootstrap.sh`

Add a required flavor selector:

- `--flavor openpod`
- `--flavor claudepod`
- `--flavor codexpod`

The bootstrap script should own common control flow only:

- argument parsing
- prefix selection
- common shared-tool installation
- common shell setup

Flavor-specific behavior should be delegated to:

- `runtime/<flavor>/install-harness.sh`

Default prefixes should vary by flavor:

- `~/.local/openpod`
- `~/.local/claudepod`
- `~/.local/codexpod`

## Vendor And Skills Model

Keep shared vendor assets only for shared tooling:

- `vendor/releases/`
- `vendor/zsh/`
- `vendor/nvim/`

Do not keep harness-specific runtime layouts in the shared vendor root unless they are truly shared.

Harness-specific skills should live in the flavor directories:

- `runtime/openpod/skills/`
- `runtime/claudepod/skills/`
- `runtime/codexpod/skills/`

If a harness requires vendored upstream snapshots, those should either:

- stay inside the flavor directory, or
- live under a clearly flavor-scoped vendor subtree

The important rule is that flavor assets must not masquerade as shared base assets.

## Boundary Rules

These are hard rules for implementation.

### Rule 1: Shared Base Cannot Reference A Harness

Files in the shared base must not contain runtime-specific behavior.

Examples:

- `Dockerfile.devpod` must not install OpenCode, Claude Code, or Codex directly
- shared build scripts must not branch on harness-specific config semantics

### Rule 2: Flavor Layers Cannot Reinstall Shared Tools

`runtime/<flavor>/install-harness.sh` may install only:

- the harness
- harness-specific wrappers
- harness-specific configs
- harness-specific skills

### Rule 3: Skills Roots Stay Fully Isolated

Do not create one global skills root and filter it dynamically per flavor.

Each flavor sees only its own skills root.

### Rule 4: Docs Must Separate Shared And Flavor-Specific Content

The main README should explain:

- what all flavors share
- how to choose a flavor

Flavor-specific behavior should live in dedicated sections or dedicated flavor docs.

## Release Model

Maintain one version source in the repository, but publish all flavor images for that release.

This keeps versioning coherent:

- same shared environment generation
- different harness flavor on top

The release pipeline should build and publish all supported flavors from the same commit.

## Migration Strategy

Do not attempt the full end-state in one step.

Use three phases.

### Phase 1: Extract Shared Base

From current `main`, extract:

- `Dockerfile.devpod`
- shared bootstrap foundation

At the end of this phase, the project should still support only OpenCode flavor publicly, but under the new architecture.

### Phase 2: Recast OpenCode As `runtime/openpod`

Move existing OpenCode-specific logic into:

- `runtime/openpod/`

The goal is to prove the new base-plus-flavor model with exactly one flavor before adding more.

### Phase 3: Add Claude And Codex Flavors

Bring in:

- `runtime/claudepod/`
- `runtime/codexpod/`

and extend:

- Dockerfiles
- compose services
- bootstrap flavor selector
- docs
- release automation

This phased approach reduces risk and keeps the repository usable throughout the migration.

## Risks

### Hidden Flavor Drift

If shared logic starts to accrete flavor-specific conditionals, the architecture will degrade into the same complexity with different file names.

### Over-Parameterization

If too many flavor-specific knobs are exposed to users, the bootstrap and Docker UX will become harder rather than simpler.

### Incomplete Migration

If old branch-specific assumptions remain in docs, vendor layout, or release flows, maintainers will continue thinking in terms of separate products rather than flavors on a shared base.

## Implementation Boundary

The first implementation plan for this design should cover:

- extracting `Dockerfile.devpod`
- introducing `runtime/openpod/`
- parameterizing bootstrap with `--flavor`
- restructuring compose for multiple flavors
- defining image naming and release flow changes

It should not attempt to fully migrate both `claudepod` and `codexpod` in the same first implementation unless the OpenCode flavor is already stable under the new architecture.
