# CLAUDE.md

Guidance for Claude Code when working in this repository.

## Project Purpose

`kiro-plasma` adds extra **user apps** on top of a minimal Kiro Plasma ISO
install. It is the Plasma-only sibling of `arcolinux-nemesis`. Strict scope:

- **Plasma user apps only.** No non-Plasma desktop apps, no typical X11 tooling,
  no development tooling.
- Assumes Plasma is already installed and repos (`nemesis_repo` etc.) are already
  configured — it does **not** set up repos or install the desktop.

## Architecture

- `0-current-choices.sh` — orchestrator. Guards on `is_plasma_installed`, then
  runs the numbered tier scripts via `run_glob`. Tiers are enabled/disabled by
  commenting their `run_glob` lines. Tier 1 + the 500 layer run by default.
- `1-choose-tiers.sh` — interactive `dialog`/`whiptail` checklist to pick tiers.
- `100/200/300/400-*` — the four tier scripts.
- `500-plasma-extras.sh` — Kiro Plasma integration layer (not a choosable tier).
- `common/common.sh` — shared helper library, copied verbatim from
  arcolinux-nemesis. Provides logging, `install_packages`, `is_plasma_installed`,
  `run_glob`, `extract_purpose`, etc.

## The tier model

Pool = arcolinux-nemesis lists (core software, nemesis software,
`kiro-desktops/plasma.sh`). Exclusions = anything in the kiro-iso packages file
(`KIB` = `kiro-iso/archiso/packages.x86_64`) + X11/non-Plasma/dev. The rest is
bucketed:

- **Tier 1** yes great · **Tier 2** maybe · **Tier 4** could not place.
- **Tier 3** unlikely — sourced from the **commented-out** lines in the kiro-iso
  packages file (filtered). For overlaps with `plasma.sh`, the Tier-3 commented
  rule wins (e.g. `kate`, `okular`).

When adding packages: keep the scope (no X11/dev/non-Plasma), and re-check new
candidates against the kiro-iso packages file so nothing already on the ISO is
re-listed.

## Style

Scripts follow the **arcolinux-nemesis** style, not the Kiro bash template:
`#!/usr/bin/env bash`, `source common/common.sh`, a `Purpose:` header block, an
install function, and `log_subsection "$(script_name) done"`. Each tier script
guards on `is_plasma_installed`.
