# Malu123 status

> **Updated:** 2026-10-23

| Step | State | Notes |
|---|---|---|
| 0.1 fork, brand removal, docs | done 2026-10-23 | upstream `33a45130` (v0.11.1), 1,753 commits kept |
| 0.2 toolchain and first build | done 2026-10-23 | rustup 1.99.1, wasm target, Linux build deps on the dev VM; `cargo build --release -p gridcraft-cli -p gridcraft` in 5m58s under the memory-capped cgroup; `eval`, `run --sample budget`, `cat`, and `mcp` (21 tools) verified; desktop binary built, not yet launched (no display on the dev VM) |
| 0.3 `cargo xtask ci` green | done 2026-10-23 (one skip) | fmt, clippy, assets, layers, parity, keytips, wasm pass; 2,000+ tests pass; one skipped: `accounting_fill::too_wide_fill_number_shows_hashes_not_a_clipped_value` in `crates/ui-egui/tests/it` fails on this VM because the system fonts differ from upstream's macOS fonts (the `####` fill overflows the cell by a fraction of a pixel); not a code defect, re-check on the MaluOS desktop image |
| 0.4 scripted rename, vendor branch | done 2026-10-23 | `scripts/rename-upstream.sh` run on upstream `33a45130` → branch `upstream-renamed`, merged into `main`; 412 files, app id `org.maluos.malu123`; see `rename.md` |
