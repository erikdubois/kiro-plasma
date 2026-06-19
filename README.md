<h1 align="center">
  <img src="kiro.jpg" alt="Kiro" width="220" />
  <br />
  Kiro Plasma
</h1>

![Last-Commit](https://img.shields.io/github/last-commit/erikdubois/kiro-plasma?style=for-the-badge)

<img alt="GitHub followers" src="https://img.shields.io/github/followers/erikdubois?style=flat">&nbsp;&nbsp;<img alt="GitHub Repo stars" src="https://img.shields.io/github/stars/erikdubois/kiro-plasma">&nbsp;&nbsp;<img alt="GitHub forks" src="https://img.shields.io/github/forks/erikdubois/kiro-plasma">

<img alt="YouTube Channel Subscribers" src="https://img.shields.io/youtube/channel/subscribers/UCJdmdUp5BrsWsYVQUylCMLg">&nbsp;&nbsp;<img alt="YouTube Channel Views" src="https://img.shields.io/youtube/channel/views/UCJdmdUp5BrsWsYVQUylCMLg">


# Kiro Plasma

Extra-software scripts for a **minimal Kiro Plasma ISO** install. Modelled on
[arcolinux-nemesis](https://github.com/erikdubois) but Plasma-only: it adds user
apps on top of the minimal ISO and groups them in tiers you can choose from.

This repo deliberately contains **no** non-Plasma desktop apps, no typical X11
tooling and no development tooling. User apps only.

## What it assumes

You are already on a minimal Kiro Plasma system:

- Plasma is installed (Wayland or X11 session present).
- `nemesis_repo` and the other repos are already configured.

So these scripts do **not** set up repos, route non-Arch systems or install the
desktop itself. They only add extra software.

## The tiers

Packages are sourced from the arcolinux-nemesis lists (core software, nemesis
software, and `kiro-desktops/plasma.sh`). Anything already shipped in the
kiro-iso packages file (`KIB` = `kiro-iso/archiso/packages.x86_64`) is dropped,
as is anything X11-only / non-Plasma / development. What remains is bucketed:

| Tier | Script | Meaning | Examples |
|------|--------|---------|----------|
| 1 | `100-install-tier1-yes-great.sh` | **yes great** | dolphin, gwenview, spectacle, ark, kdeconnect, yakuake, ktorrent, discover, partitionmanager, spotify, signal-in-tray, zapzap, insync |
| 2 | `200-install-tier2-maybe.sh` | **maybe** | cryfs, encfs, gocryptfs, kdenetwork-filesharing, lastpass |
| 3 | `300-install-tier3-unlikely.sh` | **unlikely** | office suites, email clients, PDF/note tools, scanning, kate, okular, kmail |
| 4 | `400-install-tier4-unplaced.sh` | **could not place** | breeze, kde-gtk-config, ffmpegthumbs, packagekit-qt6, unifetch |

**Tier 3** is special: its list comes from the packages that are **commented out**
in the kiro-iso packages file (considered for the ISO but not shipped), then
filtered to drop X11/non-Plasma/dev entries. That is why core KDE apps like
`kate`, `okular` and `kmail` land in Tier 3 — they are commented in the ISO, so
by rule they are offered here rather than in Tier 1. (`konsole` is excluded
entirely — it is part of Plasma for us.)

### Plasma integration layer

`500-plasma-extras.sh` is **not** a choosable tier. It installs the Kiro-on-Plasma
baseline from `nemesis_repo` (keybindings, Dolphin service menus, Surf'n Plasma
icon themes).

## Usage

Interactive picker (recommended):

```bash
./1-choose-tiers.sh
```

Or run the orchestrator, which installs Tier 1 + the Plasma integration layer by
default. Enable the other tiers by uncommenting their `run_glob` lines in
`0-current-choices.sh`:

```bash
./0-current-choices.sh
```

Each tier script can also be run standalone — they source `common/common.sh`
themselves and skip cleanly if Plasma is not present.

Set `DEBUG=true` to pause before each section.

## Maintenance

- `setup.sh` — configures the local git identity and points `origin` at the SSH
  remote for this project.
- `up.sh` — pulls, then commits and pushes the repo (runs `setup.sh` first if the
  remote is not yet SSH).
