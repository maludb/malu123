# Malu123

**The MaluOS spreadsheet: Excel-compatible, native, with an LLM assistant built in.**

Malu123 is a fork of [GridCraft](https://github.com/storytold/gridcraft), a clean-room,
open-source spreadsheet written in pure Rust. GridCraft gives us an XLSX-native engine, 500+
worksheet functions with dynamic arrays, LET and LAMBDA, charts, pivot tables, conditional
formatting, printing and PDF, and an agent surface where every ribbon button is a command
reachable over MCP, a CLI and a JSON control channel. Malu123 adds what MaluOS needs: an
assistant that reads the open workbook and acts on it through those same commands, local-first
LLM access through the MaluOS gateway and vault, MaluOS packaging and branding.

The long-run goal is an "ask me anything" tool for your numbers. We build it step by step so each
slice ships a working app and a foundation for the next. The plan is in
[`docs/malu123/plan.md`](docs/malu123/plan.md); what is built so far is in
[`docs/malu123/status.md`](docs/malu123/status.md).

## Status

Phase 0 (foundation). The app is GridCraft renamed end to end (crates, binaries, app id,
settings); no Malu123 features yet. See the plan and status.

## Build

```sh
cargo build --release -p malu123-cli -p malu123         # CLI and desktop app
cargo run --release -p malu123 -- --sample sales        # open a sample workbook
cargo xtask ci                                          # fmt, clippy, tests, assets, layers, wasm
```

Rust 1.90 or newer. On Ubuntu and MaluOS the desktop app needs `libxkbcommon-dev libwayland-dev
libgtk-3-dev libfontconfig1-dev` to build and `libxkbcommon0` plus `libvulkan1` or `libegl1` to
run. On the MaluOS dev VM, run cargo under a memory-capped cgroup (see the plan, step 0.2).

## Upstream

`upstream` is `https://github.com/storytold/gridcraft`. Every `gridcraft` name became `malu123`
through one script, `scripts/rename-upstream.sh`; upstream changes come in through the
`upstream-renamed` vendor branch (see `docs/malu123/rename.md`). Engine, formula, calc, XLSX and
chart crates stay as upstream ships them in substance; Malu123 code lives in new crates and fenced
UI hooks. GridCraft's contributor rules ([`AGENTS.md`](AGENTS.md), [`CLAUDE.md`](CLAUDE.md))
apply here unchanged, plus the Malu123 section at the top of `CLAUDE.md`.

## License and credits

Malu123 is dual-licensed under [MIT](LICENSE-MIT) or [Apache-2.0](LICENSE-APACHE), at your option,
like GridCraft. GridCraft is copyright (c) 2026 ArtCraft Team and the GridCraft contributors; the
required notices are in [NOTICE](NOTICE) and per-asset credits in
[ATTRIBUTION.md](ATTRIBUTION.md). The ArtCraft name and logos are ArtCraft trademarks and are not
part of this fork.
