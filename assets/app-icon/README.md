# Malu123 app icon

A worksheet on the MaluOS navy tile: a green header row, a tinted row-number column, faint grid
lines, a rising column series drawn over the cells, and the active cell with its fill handle. It
is original geometry written by hand for this repository (MIT OR Apache-2.0), not modelled on any
vendor's spreadsheet logo (no letters, no "X", no overlapping panels). It replaces upstream
GridCraft's placeholder ledger-page icon.

Regenerate every size with `packaging/icons.sh` (needs `resvg`). The outputs are committed.

## Palette

| Colour | Hex | Used for |
|---|---|---|
| MaluOS navy | `#16213a` | The tile, the dark columns, the active-cell outline |
| Paper | `#f4f1ea` | The sheet |
| Malu123 green | `#2fa36b` | The header row, the two leading columns, the row-number tint |

## Geometry

A 512 × 512 viewBox, clipped to a rounded square with `rx=112`. Windows and Linux use the full
tile. The macOS icons (`.icns`, `malu123-macos-512.png`) sit on Apple's grid: an 824/1024
body with a transparent margin.

## Files

| File | Use |
|---|---|
| `malu123.svg` | Canonical artwork; also `hicolor/scalable` |
| `malu123-1024.png` | 1024 px render of the full tile |
| `malu123-macos-512.png` | Runtime Dock icon on macOS (for `apps/malu123` to embed) |
| `malu123.icns` | macOS bundle icon (`CFBundleIconFile`) |
| `malu123.ico` | Windows exe icon, 16–256 px (embedded by `apps/malu123/build.rs`) |
| `hicolor/<size>/apps/org.maluos.malu123.png` | Linux icon theme, 16–512 px; the 256 px one is also the runtime window icon on Windows and Linux |
| `hicolor/scalable/apps/org.maluos.malu123.svg` | Linux scalable icon |
| `LICENSE.txt` | MIT OR Apache-2.0 |

The app ID is `org.maluos.malu123`. It's used for the hicolor icon names, the Wayland app
ID and `packaging/linux/org.maluos.malu123.desktop`.

## Regenerate

Edit `malu123.svg`, then run `packaging/icons.sh`. It needs `resvg`, and `iconutil` for the
`.icns` (macOS only). It packs the `.ico` with `cargo xtask ico`.
