# The rename: GridCraft to Malu123

> **Created:** 2026-10-23 · plan step 0.4

The owner chose to rename every crate, binary and identifier, not only the apps. One script holds
the whole mapping, `scripts/rename-upstream.sh` (paths, brand-file removal, `cargo fmt`) with the
text rules in `scripts/rename-upstream.py` (`--list` prints them). It is idempotent.

## Mapping

| Upstream | Malu123 | Where |
|---|---|---|
| `gridcraft-core`, `gridcraft-engine`, … | `malu123-core`, `malu123-engine`, … | crate names, `Cargo.toml`, `Cargo.lock` |
| `gridcraft_core::`, … | `malu123_core::`, … | Rust paths |
| `gridcraft`, `gridcraft-cli`, `gridcraft-web` | `malu123`, `malu123-cli`, `malu123-web` | packages, binaries, `apps/` directories |
| `ai.storyteller.gridcraft` | `org.maluos.malu123` | app id: desktop file, metainfo, MIME, flatpak, icon file names |
| `GRIDCRAFT_*` | `MALU123_*` | environment variables (`MALU123_NO_PREFS`, `MALU123_FUZZ_SEED`, …) |
| `GridCraft` | `Malu123` | product name: window title, About, i18n strings, XLSX `<Application>`, PDF producer, MCP server title |
| `gridcraft://workbook` … | `malu123://workbook` … | MCP resource URIs |
| `~/.config/gridcraft`, `gridcraft.log` | `~/.config/malu123`, `malu123.log` | settings and logs |
| `Learning Machines LLC` | `MaluOS` | package vendor fields |
| `getartcraft.com/apps/gridcraft` | `github.com/maludb/malu123` | homepage links in menus, packaging |
| `storytold/gridcraft` (bare repo path) | `maludb/malu123` | `repository` in `Cargo.toml`, bug tracker, release scripts |

Kept verbatim: `GridCraft contributors` and `GridCraft authors` (credits), links to upstream issues,
pull requests, releases and files (`storytold/gridcraft#123`, `/issues/`, `/pull/`, `/releases`,
`/blob/`), `contributors/contributors.json`'s repo (it lists upstream's contributors), the SonarCloud
key. `README.md`, `NOTICE`, the licences and `docs/malu123/` are never rewritten.

Not yet done by the script: the Windows MSI `UpgradeCode` GUID, Apple bundle signing identity, the
flatpak manifest's runtime details. They matter only when we ship those platforms.

## Branches

- `upstream-renamed`: `upstream/main` plus the script plus one commit that ran it. Nothing else.
- `main`: branches from `upstream-renamed` and carries all Malu123 work.

## Syncing upstream

```sh
git fetch upstream
git checkout upstream-renamed
git merge upstream/main            # git follows the moved files; conflicts are lines that
                                   # upstream changed and the rename also touched
./scripts/rename-upstream.sh       # rewrites what upstream added, resolves most conflicts
git add -A && git commit           # "sync upstream <sha>"
git checkout main
git merge upstream-renamed
cargo xtask ci
```

If a merge conflict remains after the script, resolve it by hand keeping the Malu123 names, and add
a rule to the script if the same pattern will come back.
