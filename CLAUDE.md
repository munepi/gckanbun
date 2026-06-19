# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

`gckanbun` is a LaTeX package (`gckanbun.sty`) for typesetting Classical Chinese texts (Kanbun) in traditional Japanese style. It provides commands for furigana (振り仮名), okurigana (送り仮名), kaeriten (返り点), special return marks, and Chinese poetry (漢詩) layout.

## Build commands

The recommended engine is **LuaLaTeX**. Both PDF outputs are tracked in git.

```sh
# Compile documentation
lualatex gckanbun-doc.tex

# Compile test file
lualatex gckanbun-test.tex
```

(u)pLaTeX is partially supported but has feature limitations — prefer LuaLaTeX for development and testing.

## Package architecture

All package logic lives in `gckanbun.sty`. There are no subdirectories.

### Engine detection and direction tracking

Engine detection uses `\sys_if_engine_luatex:TF` (expl3) at load time to set up engine-specific shims (`\zw`, `\zh`, ghost character macros). At `\AtBeginDocument`, it detects vertical/horizontal writing direction and sets `\l__gckanbun_tdir_bool`. The `\GCKTateOn` / `\GCKTateOff` commands set a manual-override flag (`\l__gckanbun_tdir_manual_bool`) that suppresses auto-detection; `\GCKTateAuto` resumes it. Each command call invokes `\gcknbn@autocheck@direction` to dynamically refresh the direction.

Many layout calculations branch on `\l__gckanbun_tdir_bool` (e.g., `\l__gckanbun_adjust_yokotate_dim` and `\l__gckanbun_adjust_kaeri_dim` differ between tate and yoko modes).

### Command naming and prefix system

Internal functions use the expl3 `\__gckanbun_...:` convention; internal variables use `\l__gckanbun_..._dim` (local) or `\g__gckanbun_..._dim` (global). Public commands are exposed in two ways:
1. Via the `prefix=` package option (default `gckanbun`): `\gckanbunruby`, `\gckanbungroupruby`, `\gckanbunokurigana`, `\gckanbunkaeriten`
2. Short Japanese aliases: `\振り`, `\グ振り`, `\送り`, `\返り`

### Core command internals

**`\gcknbn@ruby` (振り仮名/furigana)** — uses `\futurelet` to peek at the next token after placing the ruby box, adjusting spacing depending on whether what follows is okurigana, kaeriten, 、, 。, or other. Supports `intrusion=pre|post|both` for character intrusion into adjacent spacing.

**`\gcknbn@okurigana` (送り仮名)** — similarly peeks ahead to handle the case where kaeriten or punctuation follows, using negative kern to overlap. Tracks widths in `\g__gckanbun_okurigana_width_dim` and `\g__gckanbun_okurigana_width_s_dim` (for saidoku/re-read variant).

**`\gcknbn@kaeriten` (返り点)** — lowered half-size mark; handles punctuation following via `\futurelet`.

The three commands coordinate through shared global dimension variables (`\g__gckanbun_intr_pre_dim`, `\g__gckanbun_intr_post_dim`, `\g__gckanbun_furigana_width_dim`, etc.) that carry state between adjacent commands in the input stream. The `\futurelet` lookahead mechanism is kept as-is (TeX primitive; no expl3 migration needed).

### Special commands

- `\IchiRe`, `\JyouRe`, `\KouRe`, `\TenRe` — composite return marks (一レ点, 上レ点, etc.), with tate/yoko variants
- `GCKEnv` environment — sets `kanjiskip` for the enclosed text
- `\GCKanshiBox{width}{content}` — fixed-width box for 漢詩 line alignment
- `\KanHyphen` — em dash (`U+2015`) for Kanbun

### Files

| File | Purpose |
|---|---|
| `gckanbun.sty` | The package itself |
| `gckanbun-doc.tex` / `.pdf` | Full documentation with examples |
| `gckanbun-test.tex` / `.pdf` | Minimal test showcasing key commands |
| `gckanbun-sample.tex` / `.pdf` | Standalone LuaLaTeX usage example |

## Implementation history

- **v2.3.0** — Per-command direction auto-detection; `\GCKTateAuto`; internal bug fixes
- **v2.3.2** — `\KanHyphen` kanjiskip suppression; `\llap` → `\makebox[0pt][r]` in special return marks; group ruby removed
- **v2.4.0** — Full expl3 migration: `\dim_new:N`, `\bool_new:N`, `l3keys2e`, `\dim_compare:nNnTF`, named scratch boxes, load-time engine branching; `\AtBeginDocument` manual-flag bug fix
- **v2.4.1** — Suppress glue at the outer ruby-box boundary when `\KanHyphen` is the parent character
- **v2.5.0** — Restore group ruby as `\gckanbungroupruby` / `\グ振り` with LuaTeX-ja-compatible spacing
