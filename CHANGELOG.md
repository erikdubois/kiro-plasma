# Changelog

## 2026.06.19

### Override-shortcuts script (close window + 7 F-key app launches)
- Renamed `apply-close-window-shortcut.sh` → **`apply-override-shortcuts.sh`** and
  broadened it: it now applies all Kiro keybindings that must override a built-in
  KWin action (which the add-only `kiro-plasma-keybindings` package cannot do).
- Keeps `Super+Shift+Q` → KWin "Close Window" (`Alt+F4` retained).
- Adds the 7 `Super+F#` app launches that collide with Plasma defaults: VS Code
  (F2), Inkscape (F3), GIMP (F4), Meld (F5), VLC (F6), VirtualBox (F7),
  virt-manager (F9). For each it frees the conflicting key from the KWin action
  (read-modify-write that strips only that token, preserving KDE's default and
  friendly-name fields) and binds the key via a `[services][<id>] _launch` entry.
- Only binds apps that are actually installed (resolves the real `.desktop` id
  from candidate names across `/usr/share`, `~/.local/share`, and flatpak dirs),
  so uninstalled apps leave the Plasma default intact — no dead keys.
- Verified on a Plasma 6 VM: close-window applies, uninstalled apps skip cleanly,
  and (with a stub `code.desktop`) `Meta+F2` is freed from "Switch to Desktop 2"
  and bound to `[services][code.desktop]`.

### What Changed
- Created the initial `kiro-plasma` script suite — a Plasma-only equivalent of
  `arcolinux-nemesis`, for adding extra user apps on top of a minimal Kiro Plasma
  ISO install. No non-Plasma desktop apps, no X11-only tooling, no development
  tooling.
- Added a four-tier package model the user can choose from:
  - Tier 1 (yes great), Tier 2 (maybe), Tier 3 (unlikely), Tier 4 (could not place).
- Added the orchestrator, an interactive tier picker, and a Plasma integration
  layer script.

### Technical Details
- Package pool comes from the arcolinux-nemesis lists (core software, nemesis
  software, `kiro-desktops/plasma.sh`). Everything already shipped in the kiro-iso
  packages file (`KIB` = `kiro-iso/archiso/packages.x86_64`, ~389 active packages)
  is excluded, as is anything X11-only / non-Plasma / development.
- Tier 3 is sourced specifically from the **commented-out** package lines in the
  kiro-iso packages file (~143 lines, "considered but not shipped"), then filtered
  for Plasma/user relevance. This is why core KDE apps that the ISO keeps commented
  (kate, okular, kmail) land in Tier 3 rather than Tier 1. konsole is excluded
  entirely — it is treated as part of Plasma.
- For packages present in both `plasma.sh` and the kiro-iso commented list
  (kate, okular), the Tier 3 commented-source rule wins.
- `common/common.sh` copied verbatim from arcolinux-nemesis as the shared helper
  library (logging, `install_packages`, `is_plasma_installed`, `run_glob`,
  `extract_purpose`, etc.). The non-Arch `handle.sh` and repo-setup machinery were
  intentionally not carried over — this suite assumes repos are already configured
  on the ISO.
- Every tier script guards on `is_plasma_installed` and skips cleanly otherwise.
- Scripts mirror the arcolinux-nemesis style (`#!/usr/bin/env bash`, source
  common, Purpose header block, install function, `log_subsection done`) rather
  than the Kiro bash template, to read like the upstream repo they copy.
- Assumption flagged: exclusion is based solely on the kiro-iso packages.x86_64
  per instruction. KDE apps installed on the target by Calamares (plasma-meta /
  kde-system-meta) are not in that file, so they were tiered, not excluded.

### Files Modified
- `0-current-choices.sh` (new) — orchestrator
- `1-choose-tiers.sh` (new) — interactive tier picker
- `100-install-tier1-yes-great.sh` (new)
- `200-install-tier2-maybe.sh` (new)
- `300-install-tier3-unlikely.sh` (new)
- `400-install-tier4-unplaced.sh` (new)
- `500-plasma-extras.sh` (new) — Kiro Plasma integration layer
- `common/common.sh` (new) — shared helper library (copied from arcolinux-nemesis)
- `setup.sh`, `up.sh` (new) — standard Kiro git config + pull/commit/push helpers
  (copied from arcolinux-nemesis; path routing resolves to the erikdubois remote)
- `README.md`, `CHANGELOG.md`, `CLAUDE.md` (new)
