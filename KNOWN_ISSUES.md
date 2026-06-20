# gckanbun: Known Issues and Follow-up Work

Last reviewed: 2026-06-21

This document records issues that remain after the v2.5.2 group-ruby and
return-mark fixes. Items marked **confirmed** were reproduced locally. Items
marked **risk** are implementation or maintenance risks that need a dedicated
test before being treated as user-visible bugs.

## Priority Summary

| Priority | Status | Area | Issue |
| --- | --- | --- | --- |
| P1 | Confirmed | Command parsing | Whitespace between related commands changes layout and disables lookahead handling |
| P1 | Confirmed | Build | `gckanbun-doc.pdf` does not depend on the embedded `gckanbun-test.pdf` |
| P1 | Confirmed | Regression tests | Current assertions verify box metrics, but not actual glyph overlap or coordinates |
| P2 | Confirmed | Option handling | Invalid `intrusion` values are silently accepted |
| P2 | Confirmed | Build coverage | `make all` does not run the upLaTeX smoke test |
| P2 | Confirmed | Distribution | The CTAN ZIP omits the advertised upLaTeX edge-test files |
| P2 | Confirmed | Engine coverage | upLaTeX coverage is visual-only and has no full vertical-writing matrix |
| P2 | Confirmed | Reproducibility | Documentation requires macOS Hiragino fonts and emits font substitutions elsewhere |
| P2 | Risk | Internal state | Layout commands communicate through mutable global dimensions and booleans |
| P3 | Confirmed | Test maintenance | Horizontal and vertical edge matrices duplicate most cases manually |
| P3 | Confirmed | Documentation build | The documentation currently emits known layout and class warnings |
| P3 | Confirmed | Automation | No CI or `l3build`-style automated regression runner is present |

## 1. Whitespace-sensitive command chaining

**Status:** Confirmed  
**Priority:** P1

The package intentionally preserves a `\futurelet`-based lookahead mechanism.
It only recognizes the immediately following token. A literal space or line
break between commands therefore changes behavior.

For example:

```tex
\グ振り{読}{よ}\返り{レ}書
\グ振り{読}{よ} \返り{レ}書
```

These are not equivalent. A local LuaLaTeX probe measured:

```text
adjacent: 22.5pt
with space: 25.587pt
```

The same problem affects group ruby followed by `\送り`; the lookahead no
longer initializes the annotation widths expected by the following command.

Recommended follow-up:

- Decide whether whitespace should be ignored between cooperating commands.
- If yes, add a space-skipping lookahead helper without changing public syntax.
- Add horizontal, full-vertical, and upLaTeX regression cases containing
  spaces, newlines, comments, and grouping between commands.

## 2. Missing Makefile dependency for the documentation PDF

**Status:** Confirmed  
**Priority:** P1

`gckanbun-doc.tex` embeds `gckanbun-test.pdf`, but the generic rule only records
dependencies on the matching `.tex` file and `gckanbun.sty`.

After `make distclean`, a parallel or documentation-first build can attempt to
compile the manual before `gckanbun-test.pdf` exists. The resulting
`gckanbun-doc.pdf` can then remain newer than its declared prerequisites and be
incorrectly treated as up to date.

Recommended follow-up:

```make
gckanbun-doc.pdf: gckanbun-doc.tex gckanbun.sty gckanbun-test.pdf
```

The dependency graph should also be tested with:

```sh
make distclean
make -j all
```

## 3. No automated overlap or coordinate assertion

**Status:** Confirmed  
**Priority:** P1

The edge tests now check selected widths, heights, and depths. Those checks
would not have caught the original defect where a return mark had the expected
overall width but visibly overlapped the preceding parent character.

Recommended follow-up:

- Add Lua node-list inspection for glyph bounding boxes and horizontal or
  vertical coordinates.
- Alternatively, render stable cropped fixtures and compare them with a small
  pixel tolerance.
- Keep human-readable PDF matrices, but do not rely on visual inspection as the
  only overlap detector.

## 4. Invalid `intrusion` values are silently accepted

**Status:** Confirmed  
**Priority:** P2

The keys use unrestricted `.tl_set:N` handlers. A typo such as:

```tex
\グ振り[intrusion=typo]{天地}{てんちげんこう}
```

produces no package warning or error and behaves like an unspecified value.
This makes user mistakes difficult to diagnose.

Recommended follow-up:

- Replace unrestricted token-list keys with `.choice:` keys.
- Define accepted values explicitly:
  - ruby: `pre`, `post`, `both`
  - okurigana and kaeriten: `post`, `both`
- Emit a package error containing the invalid value and accepted choices.

## 5. `make all` excludes upLaTeX validation

**Status:** Confirmed  
**Priority:** P2

`all` only depends on LuaLaTeX PDFs. The upLaTeX smoke test must be invoked
separately, so a successful `make` does not mean all supported engines passed.

Recommended follow-up:

- Add a `check` target that runs both LuaLaTeX matrices and upLaTeX.
- Keep `all` for normal PDF generation if desired, but document `make check` as
  the release gate.

## 6. CTAN archive omits the upLaTeX edge test

**Status:** Confirmed  
**Priority:** P2

The README advertises `make edge-test-uptex`, and the repository tracks both
`gckanbun-edge-test-uptex.tex` and its PDF. They are not listed in
`CTAN_FILES`, so `make zip` excludes them.

Recommended follow-up:

- Either include the upLaTeX source and PDF in `CTAN_FILES`, or explicitly mark
  them as development-only and remove the public README instruction from the
  distribution.

## 7. Limited upLaTeX regression coverage

**Status:** Confirmed  
**Priority:** P2

The upLaTeX file is a one-page visual smoke test. It has no metric assertions
and no dedicated `tate` document equivalent to
`gckanbun-edge-test-tate.tex`.

Recommended follow-up:

- Add an upLaTeX vertical-writing matrix.
- Port engine-neutral metric assertions where pTeX dimensions permit it.
- Include long ruby, long reread ruby, return-mark width, punctuation, font
  size, alias, braced `\KanHyphen`, and whitespace cases.

## 8. Platform-specific documentation fonts

**Status:** Confirmed  
**Priority:** P2

The documentation directly requests macOS Hiragino Pro fonts. Builds on systems
without the same fonts substitute faces or fail, and PDF layout can differ by
platform.

Observed warnings include missing `HiraMinPro-W2` and substituted font shapes.

Recommended follow-up:

- Use TeX Live fonts such as Harano Aji for the reproducible default build.
- Keep Hiragino as an optional documented build profile if desired.
- Record the expected TeX Live version and font profile used for tracked PDFs.

## 9. Mutable global annotation state

**Status:** Risk  
**Priority:** P2

Ruby, okurigana, and kaeriten exchange dimensions and flags through several
global variables. Recent bugs have already involved stale intrusion state.
Early exits, unexpected expansion paths, unsupported nesting, or future command
extensions can leave state that affects later input.

Recommended follow-up:

- Encapsulate annotation state in a single initialization and finalization
  protocol.
- Reset the group-follow flag and shift dimension defensively at command entry.
- Add tests where commands occur inside boxes, groups, macro wrappers, failed
  option parses, and unsupported nested input.
- Consider replacing implicit global hand-off with an explicit composite
  command or structured property state in a future major version.

## 10. Duplicated horizontal and vertical matrices

**Status:** Confirmed  
**Priority:** P3

The horizontal and vertical LuaLaTeX test files duplicate most test cases.
Future additions can easily be made to one direction only.

Recommended follow-up:

- Move shared cases and assertions to a small test support file.
- Keep only document-class and direction-specific wrappers in each matrix.

## 11. Known documentation warnings

**Status:** Confirmed  
**Priority:** P3

The current documentation build emits:

- a `jlreq` warning that `paper=b5` means ISO B5 rather than JIS B5;
- a `caption` warning about the unknown document class;
- Hiragino font substitution warnings;
- an overfull `\vbox` of approximately `0.71pt`.

Recommended follow-up:

- Decide explicitly between `paper=b5` and `paper=b5j`.
- Remove `caption` if it is unnecessary, or configure it for `jlreq`.
- Fix or consciously suppress the small overfull box after locating the page
  element responsible.

## 12. No continuous integration

**Status:** Confirmed  
**Priority:** P3

There is no repository CI workflow and no `l3build` regression suite. Tracked
PDFs and log inspection currently depend on local manual execution.

Recommended follow-up:

- Add CI with a pinned TeX Live image.
- Run LuaLaTeX horizontal and vertical matrices, upLaTeX smoke tests, log
  scanning, and `make zip`.
- Fail on TeX errors, undefined commands, assertion failures, and unexpected
  overfull boxes in regression documents.

## Suggested Implementation Order

1. Fix Makefile dependencies and add `make check`.
2. Make lookahead whitespace behavior explicit and test it.
3. Validate `intrusion` values.
4. Add coordinate- or image-based overlap assertions.
5. Expand upLaTeX vertical coverage.
6. Make documentation fonts reproducible.
7. Reduce global-state coupling and test duplication.
