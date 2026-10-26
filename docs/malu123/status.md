# Malu123 status

> **Updated:** 2026-10-26

| Step | State | Notes |
|---|---|---|
| 0.1 fork, brand removal, docs | done 2026-10-23 | upstream `33a45130` (v0.11.1), 1,753 commits kept |
| 0.2 toolchain and first build | done 2026-10-23 | rustup 1.99.1, wasm target, Linux build deps on the dev VM; `cargo build --release -p gridcraft-cli -p gridcraft` in 5m58s under the memory-capped cgroup; `eval`, `run --sample budget`, `cat`, and `mcp` (21 tools) verified; desktop binary built, not yet launched (no display on the dev VM) |
| 0.3 `cargo xtask ci` green | done 2026-10-23 (one skip) | fmt, clippy, assets, layers, parity, keytips, wasm pass; 2,000+ tests pass; one skipped: `accounting_fill::too_wide_fill_number_shows_hashes_not_a_clipped_value` in `crates/ui-egui/tests/it` fails on this VM because the system fonts differ from upstream's macOS fonts (the `####` fill overflows the cell by a fraction of a pixel); not a code defect, re-check on the MaluOS desktop image |
| 0.4 scripted rename, vendor branch | done 2026-10-23 | `scripts/rename-upstream.sh` run on upstream `33a45130` → branch `upstream-renamed`, merged into `main`; 412 files, app id `org.maluos.malu123`; see `rename.md`. CI on the renamed tree: fmt, clippy, doctest, assets, layers, parity, keytips, wasm pass; 2,167 tests pass, the one font skip from 0.3 remains; `malu123-cli eval`, `malu123 --version` and the MCP server (`serverInfo.name` = `malu123`) verified |

## Phase 1: Malu123 the spreadsheet

| Step | State | Notes |
|---|---|---|
| 1.1 app identity | done 2026-10-26 | original icon (worksheet, rising columns, MaluOS navy `#16213a`, green `#2fa36b`), all sizes via `packaging/icons.sh` (resvg; the macOS `.icns` is stale, Linux-only target); About box names Malu123 and credits GridCraft; window title, `--version`, MCP `serverInfo` say Malu123. The rename script now sets the deb maintainer (`Edward Honour <ed@maludb.org>`) and AppStream developer id `org.maluos` |
| 1.2 settings and logs | done 2026-10-26 | a fresh HOME gets `~/.config/malu123/logs/malu123.log` on first start (verified with the installed binary under Xvfb) |
| 1.3 deb packaging | done 2026-10-26 | `packaging/linux/package.sh --skip-build --formats "deb tar"` (nfpm): `malu123-0.11.1-linux-x86_64.deb`, 20 MB; desktop file and AppStream metainfo validate; installed on the dev VM with apt; `malu123-cli eval`, `malu123 --control` + `ui.screenshot` and `engine.execute` work under Xvfb. Vendored into the maluos repo as `vendor/malu123/` (refresh: `scripts/vendor-malu123-deb.sh`), `malu123` added to `seeds/desktop.seed`, maluos-meta 0.2.12 (maluos commit d843258) |
| 1.4 boot test, ISO, release | waiting | needs the maluos image chain (publish the apt repo with maluos-meta 0.2.12, desktop rootfs, qcow2, UEFI boot test, ISO); run it with the next MaluOS release rather than in parallel with the Phase 13 GPU work in that repo |
| 1.5 fonts | done 2026-10-26 (dev VM) | Malu123 bundles no fonts and reads the system's; the desktop seed ships fonts-ubuntu, fonts-noto-core, fonts-noto-color-emoji and fonts-liberation; the sample dashboard renders cleanly on the dev VM (same font set). CJK and Arabic shaping stay an upstream gap (#5) |
| 1.6 web app | in progress | `trunk` installing; `packaging/web/package.sh` builds `dist/web` |
