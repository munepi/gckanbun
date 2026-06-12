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

The package auto-detects the TeX engine via `ifuptex`/`ifluatex` at load time and sets up engine-specific shims (`\zw`, `\zh`, ghost character macros). At `\AtBeginDocument`, it detects vertical/horizontal writing direction and sets `\ifgcknbn@tdir`. The `\GCKTateOn` / `\GCKTateOff` commands allow manual override.

Many layout calculations branch on `\ifgcknbn@tdir` (e.g., the `gcknbn@adjust@yokotate` and `gcknbn@adjust@kaeri` lengths differ between tate and yoko modes).

### Command naming and prefix system

Internal commands use the `gcknbn@` prefix. Public commands are exposed in two ways:
1. Via the `prefix=` package option (default `gckanbun`): `\gckanbunruby`, `\gckanbunokurigana`, `\gckanbunkaeriten`
2. Short Japanese aliases: `\振り`, `\送り`, `\返り`

### Core command internals

**`\gcknbn@ruby` (振り仮名/furigana)** — uses `\futurelet` to peek at the next token after placing the ruby box, adjusting spacing depending on whether what follows is okurigana, kaeriten, 、, 。, or other. Supports `intrusion=pre|post|both` for character intrusion into adjacent spacing.

**`\gcknbn@okurigana` (送り仮名)** — similarly peeks ahead to handle the case where kaeriten or punctuation follows, using negative kern to overlap. Tracks widths in `\gcknbn@okurigana@width` and `@width@s` (for saidoku/re-read variant).

**`\gcknbn@kaeriten` (返り点)** — lowered half-size mark; handles punctuation following via `\futurelet`.

The three commands coordinate through shared dimension registers (`\gcknbn@intr@pre`, `\gcknbn@intr@post`, `\gcknbn@furigana@width`, etc.) that carry state between adjacent commands in the input stream.

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

## Planned enhancements (enhancement1.md)

1. **Partial vertical writing auto-detection** — use `\AddToHook` to trigger `\GCKTateOn`/`\GCKTateOff` automatically
2. **Group ruby** — modeled on `luatexja-ruby`, without breaking the existing command UI
3. **expl3 migration** — last step; requires careful testing (planning with Fable, testing/git with Sonnet)
