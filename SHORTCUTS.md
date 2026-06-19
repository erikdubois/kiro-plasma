# Kiro Plasma — Override Shortcuts

Keyboard shortcuts that **rebind a built-in KWin action**, applied by
[`apply-override-shortcuts.sh`](./apply-override-shortcuts.sh). `Super` and `Meta` are
the same key (the Windows/⌘ key); KDE labels it `Meta`.

These can't ship in the add-only `kiro-plasma-keybindings` package (that one only
*adds* launcher shortcuts and never touches KWin defaults). They are an **opt-in,
per-user** step — run the script once:

```bash
~/DATA/kiro-plasma/apply-override-shortcuts.sh
```

It writes `~/.config/kglobalshortcutsrc` via `kwriteconfig6` and reloads kglobalaccel,
so the bindings take effect without logging out. Each F-key app is bound **only if it's
installed** — otherwise the Plasma default is left intact (no dead keys).

| Shortcut | Action | Replaces Plasma default |
|---|---|---|
| `Alt+F4`, `Super+Shift+Q` | Close Window | (adds `Super+Shift+Q`; `Alt+F4` kept) |
| `Super+F2` | VS Code | Switch to Desktop 2 |
| `Super+F3` | Inkscape | Switch to Desktop 3 |
| `Super+F4` | GIMP | Switch to Desktop 4 |
| `Super+F5` | Meld | Move Mouse to Focus |
| `Super+F6` | VLC | Move Mouse to Center |
| `Super+F7` | VirtualBox | Present Windows (Window class) |
| `Super+F9` | virt-manager | Present Windows (Current desktop) |

> Because these rebind built-ins, they don't revert on their own — resetting those
> actions in *System Settings → Shortcuts* (or re-running stock KDE) undoes them.

## See also

The everyday launcher shortcuts (terminal, browsers, tools — `Meta+Return`,
`Ctrl+Alt+*`, etc.) are shipped add-only by the **`kiro-plasma-keybindings`** package;
its `SHORTCUTS.md` has the full list.
