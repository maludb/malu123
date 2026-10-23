# Malu123 plan

> **Created:** 2026-10-23 · **Status:** Phase 0 in progress · **Upstream:** [storytold/gridcraft](https://github.com/storytold/gridcraft) at `33a45130` (v0.11.1)

Malu123 is the MaluOS spreadsheet: an Excel-compatible desktop app with an LLM assistant built
in. It is a fork of GridCraft, a clean-room Rust spreadsheet with an XLSX-native engine, a
500-function formula library, charts, pivots, and an agent surface (MCP server, CLI, JSON control
channel). The long-run goal is an "ask me anything" tool that works on the open workbook: the
person types a question or an instruction in plain language, the assistant reads the sheet,
plans, runs engine commands, and shows what it changed. We get there step by step, so each slice
leaves a releasable app and a foundation the next slice builds on.

## Why GridCraft

| What we need | What GridCraft gives us |
|---|---|
| Excel compatibility | XLSX is the native format: styles, formulas with dynamic arrays, tables, CF, validation, charts, pivots, print settings round-trip; CSV/TSV; `.xls`, XLSB, ODS import |
| A real engine | Dependency-graph recalc, 513 of 523 Excel functions catalogued (504 working), LET/LAMBDA, structured references, copy-on-write undo |
| An LLM-ready surface | Every ribbon button is a command (`home.bold`, `data.sort`, `cell.set`…); all commands reachable over MCP, CLI and a TCP control channel; `inspect_workbook`, `read_range`, `evaluate_formula`, `screenshot` already exist |
| Fits MaluOS | Pure Rust, one static binary plus a CLI, no telemetry, no licence server, deb packaging via nfpm, MIT OR Apache-2.0 |
| A safe base to extend | Enforced crate layering (`cargo xtask layers`), never-crash policy, command fuzzing, 160k lines with tests |

What it does not have: any LLM client, any chat UI, any MaluOS integration (vault, gateway,
agents), or MaluOS branding. That is Malu123's work.

## Principles

1. **Stay mergeable with upstream.** GridCraft moves fast (1,750 commits, 50 open PRs). Our
   value is the assistant and the MaluOS fit, not a better spreadsheet engine. Engine, formula,
   calc, xlsx and chart crates stay untouched except for upstream merges and bug fixes sent
   upstream. Malu123 code lives in new crates and in clearly fenced UI hooks. We merge
   `upstream/main` monthly or per upstream release.
2. **Everything the assistant does is a command.** The assistant never pokes the model directly.
   It calls the same command catalog a person's click calls, so undo, history, the control channel
   and tests all cover it for free.
3. **Local first, provider agnostic.** The LLM client speaks one trait with pluggable backends:
   the MaluOS gateway and local agents first, cloud providers (Claude API, OpenAI-compatible)
   behind the vault. Keys never live in the workbook or in settings files in the clear.
4. **Never crash, never silently change numbers.** The assistant proposes, the engine executes,
   the person sees a diff and can undo. No unwrap, no panics (GridCraft's policy stays in force).
5. **Rust only; no handwritten JS/TS; wasm keeps building.** The web build is not a MaluOS
   target today but we do not break it, because it is upstream's CI gate too.
6. **One slice per commit set, boot-tested on MaluOS before release**, as with the other
   MaluOS packages (see `maluos/docs/roadmap.md` conventions).

## Architecture after the fork

```
L0  core · numfmt                                  (upstream, untouched)
L1  formula · functions                            (upstream, untouched)
L2  model · calc · xlsx                            (upstream, untouched)
L3  chart · pdf                                    (upstream, untouched)
L5  engine                                         (upstream; Malu123 adds commands under cmd/assist.rs only if needed)
L5  malu123-llm   NEW  LLM client trait + backends (gateway, local agent, Claude API, OpenAI-compatible); no egui
L5  malu123-assist NEW  the assistant: context builder (workbook → prompt), tool schema from the
                        command catalog, plan/act loop, change log, safety rails; depends on engine + malu123-llm
L6  ui-egui                                        (upstream + Malu123 assistant pane, settings page, branding hooks)
L6  mcp                                            (upstream, untouched)
L7  apps/malu123 · apps/malu123-cli · apps/gridcraft-web
```

The two new crates sit beside `engine` at L5 and `cargo xtask layers` is extended so nothing
below L6 links egui, and nothing below L5 links `malu123-llm`. The MCP server and the assistant
share one source of truth for tool definitions: the command catalog (`crates/engine/src/catalog.rs`).

## Phases

Estimates are agent-hours on this host (one agent, release builds take ~10 min).

### Phase 0: foundation (this week)

| Step | Work | Done when |
|---|---|---|
| 0.1 | Fork: full upstream history, `origin` = maludb/malu123, `upstream` = storytold/gridcraft; remove ArtCraft brand files (required by their licence); Malu123 README, CLAUDE.md, this plan | pushed |
| 0.2 | Toolchain on the dev host: rustup, wasm target, Linux build deps; release build of the CLI and desktop app under a memory-capped cgroup (the dev VM dies on page-cache pressure) | `gridcraft-cli eval '=SUM(1,2,3)'` prints 6; the desktop binary links |
| 0.3 | `cargo xtask ci` passes on this host (fmt, clippy, tests, assets, layers, wasm); note any test that needs a font dir or corpus and skip it deliberately | green, with a list of skipped tests in `docs/malu123/status.md` |
| 0.4 | Rename plan decided: binaries `malu123` and `malu123-cli`, app id `com.maludb.malu123`, config dir `~/.config/malu123`, log name, desktop file, MIME file. Crate names stay `gridcraft-*` for mergeability; only the L7 apps and packaging are renamed | written up in `docs/malu123/rename.md` before any sed |

### Phase 1: Malu123 the spreadsheet (ship something)

| Step | Work | Done when |
|---|---|---|
| 1.1 | Rename L7 apps and packaging per 0.4; app icon (original SVG, MaluOS palette), window title, About box, credits page keeps GridCraft attribution | app runs as Malu123 |
| 1.2 | Settings dir, logs and preferences under the Malu123 name; migration from nothing (fresh install) | fresh profile works |
| 1.3 | Deb packaging the MaluOS way: `packages/malu123` in the maluos repo with `debian/`, built by `scripts/build-packages.sh`, depends on the runtime libs nfpm lists (libxkbcommon0, libvulkan1 or libegl1, wayland/x11 recommends); desktop file in the MaluOS Office folder of the GNOME grid | `.deb` installs on a desktop image; launches from the grid; opens `.xlsx` by double-click |
| 1.4 | Boot test on the desktop image; add to the Phase 12 desktop ISO; release on apt.maluos.com | in a MaluOS release |
| 1.5 | Fonts: MaluOS ships its own fonts; point `CRAFT_FONTS_DIR` at nothing and verify system-font fallback renders Latin, CJK and Arabic acceptably on the desktop image (upstream gap #5) | screenshots in `docs/malu123/status.md` |

### Phase 2: the LLM client crate (`malu123-llm`)

| Step | Work | Done when |
|---|---|---|
| 2.1 | `LlmClient` trait: `complete(request) -> Result<Stream<Event>>` with messages, system prompt, tool definitions, tool results, streaming text and tool-call events, token usage; typed error enum | unit tests with a mock backend |
| 2.2 | Backend: MaluOS gateway (`/run/maluos/gateway.sock`, Unix socket, peer credentials) and local agent task interface (`/run/maluos/agents/NAME/tasks.sock`, JSON-RPC shaped like A2A); this is the default on MaluOS and needs no key | works against the demo agent on the dev VM |
| 2.3 | Backend: Claude API (Messages API, streaming, tool use, prompt caching for the workbook context); key from the MaluOS vault (`/run/maluos/vault.sock`) or from an env var off-MaluOS | integration test behind `MALU123_LIVE_LLM=1` |
| 2.4 | Backend: OpenAI-compatible HTTP (covers local servers: llama.cpp, vLLM, the future maluos-local-llm-server) | same test |
| 2.5 | HTTP transport choice: `ureq` (blocking, rustls, no tokio) on native; `ehttp` on wasm so the web build still compiles with the assistant stubbed | wasm gate stays green |
| 2.6 | Provider settings: a `malu123.toml` in the config dir (provider, model, endpoint) edited from a settings dialog; never stores keys | dialog works, file round-trips |

### Phase 3: the assistant crate (`malu123-assist`) and pane

| Step | Work | Done when |
|---|---|---|
| 3.1 | Context builder: workbook summary for the prompt (sheets, used ranges, headers, tables, names, selection, the first N rows of the active region, formulas in the selection), size-capped with truncation markers; cache keyed on workbook revision | snapshot tests on the sample workbooks |
| 3.2 | Tool schema generated from the command catalog, same mapping the MCP server uses (`read_range`, `write_range`, `set_cell`, `evaluate_formula`, `format_range`, `insert_chart`, `create_table`, `sort_range`, `filter`, `execute_command`, `inspect_workbook`); one table drives both MCP and the assistant | MCP tests still pass; schema JSON snapshot |
| 3.3 | The loop: user message → prompt → model → tool calls executed through `Session::execute` as one undoable history group per turn → tool results back → final answer; hard limits on turns, tool calls and tokens | headless test with the mock backend: "sum column B into B10" produces the right formula |
| 3.4 | Safety rails: read-only mode (answers only), confirm-before-write mode (shows the planned commands, applies on OK), autopilot (applies, shows the diff); destructive commands (delete sheet, clear, overwrite non-empty cells outside the selection) always confirm | tests per mode |
| 3.5 | Assistant pane in the UI (right-hand pane like the Pivot Table Fields pane): conversation, streaming answer, the commands it ran with Undo per turn, mode selector, provider status; "Ask Malu" ribbon button and `Ctrl+Shift+A` | screenshots in status.md |
| 3.6 | `malu123-cli ask "…" --in book.xlsx --out book.xlsx` for scripts and tests; the same loop headless | documented in `docs/malu123/cli.md` |

### Phase 4: ask me anything, depth

| Step | Work |
|---|---|
| 4.1 | Explain: "what does this formula do", "why is this #REF!", "where does B12 come from" using the dependency graph (precedents/dependents) |
| 4.2 | Data questions over large ranges: the assistant writes a formula or a pivot instead of reading rows into the prompt; sampling and `evaluate_formula` instead of dumping data |
| 4.3 | Charts and formatting by description ("make this a dashboard like the sales sample") |
| 4.4 | Imports: "open the CSV in Downloads and tidy it" (Flash Fill, Text to Columns, Remove Duplicates through commands) |
| 4.5 | Memory across sessions: per-workbook notes stored in the XLSX as a custom XML part (pass-through already keeps custom XML), nothing outside the file |
| 4.6 | MaluOS office integration: the assistant can hand a task to an office agent (Phase 13 delegation envelope) and bring the result into the sheet |

### Phase 5: polish and parity

Track upstream's beta gates (XLSX on a real corpus, 100 MB workbooks, chart depth, text shaping)
by merging upstream; contribute fixes we make upstream. Localization: upstream has 19 UI
languages; the assistant prompt follows the UI language.

## Repository conventions

- `docs/malu123/` holds everything Malu123-specific: this plan, `status.md` (what is built, boot
  test results, skipped tests), `rename.md`, `llm.md`, `assistant.md`, `packaging.md`.
  Upstream docs stay where they are and are not edited except to fix fork-breaking references.
- Commits: one step id per commit (`M0.2: toolchain and first build`), as upstream does with its
  task ids. Co-author lines as the MaluOS repos use them.
- Branches: `main` is ours; `upstream/main` is tracked; merges land as merge commits so the
  history shows what came from where.
- Quality gates before every push: `cargo xtask ci`. New Malu123 crates follow upstream's clippy
  denies (`unwrap_used`, `expect_used`, `panic`, `todo`, `unreachable`).
- Never commit: fonts, Excel-authored files, screenshots of Microsoft software, API keys,
  `plan/` (gitignored, local).

## Open decisions for the owner

1. **Default provider on MaluOS**: the gateway/agent route (no key, works offline with the local
   LLM server) or the Claude API (better answers, needs a key in the vault)? The plan builds both;
   the default affects the first-run experience.
2. **Crate names**: keep `gridcraft-*` for mergeability (recommended) or rename everything to
   `malu123-*` now and pay for every upstream merge?
3. **Web build**: keep it compiling only (recommended) or ship it as a MaluOS web app too?
4. **App id**: `com.maludb.malu123` or `org.maluos.malu123`? (The other MaluOS packages use
   the `maluos-` prefix and `maludb.org` for the maintainer.)
