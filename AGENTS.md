# Repository Guidelines

## Project Structure & Module Organization

`gckanbun.sty` contains the complete package implementation. Public commands include Japanese aliases such as `\振り`, `\送り`, and `\返り`, plus prefix-based commands configured through the package option.

- `gckanbun-doc.tex` / `.pdf`: user documentation and full examples.
- `gckanbun-test.tex` / `.pdf`: compact regression and visual test cases.
- `gckanbun-sample.tex` / `.pdf`: minimal standalone LuaLaTeX example.
- `README.md`: package overview, version, and compatibility notes.
- `Makefile` and `.latexmkrc`: LuaLaTeX build configuration.
- `task/`: design notes and issue descriptions.
- `luatexja/` and `kanbun/`: reference implementations; consult relevant ruby, glue, and Kanbun layout code before changing spacing behavior.

## Build, Test, and Development Commands

LuaLaTeX is the primary development engine.

```sh
make             # Build documentation and test PDFs
make doc         # Build gckanbun-doc.pdf
make test        # Build gckanbun-test.pdf
make sample      # Build gckanbun-sample.pdf
latexmk -g gckanbun-test.tex  # Force a clean regression rebuild
make clean       # Remove auxiliary files, preserving PDFs
make distclean   # Remove auxiliary files and generated PDFs
```

Both PDFs are tracked. Rebuild and include them whenever their TeX sources or package output changes. Check logs for TeX errors, undefined commands, and unexpected overfull or underfull boxes.

## Coding Style & Naming Conventions

Follow the existing expl3 conventions in `gckanbun.sty`: internal functions use `\__gckanbun_...:`, local variables use `\l__gckanbun_...`, and global shared state uses `\g__gckanbun_...`. Use two-space indentation inside TeX groups and key definitions. Preserve the established `\futurelet` lookahead mechanism unless a change explicitly requires redesigning it. Keep public command names and prefix aliases backward compatible.

## Testing Guidelines

Add minimal regression examples to `gckanbun-test.tex`; add user-facing examples and explanations to `gckanbun-doc.tex`. Test vertical and horizontal layout when spacing or direction logic changes. LuaLaTeX coverage is required; run an upLaTeX smoke test for engine-neutral changes when available. Visually inspect generated PDFs because placement defects are not reliably detected from logs.

## Commit & Pull Request Guidelines

Use short, imperative commit subjects, for example `Fix KanHyphen intrusion spacing` or `Add group ruby support`. Keep each commit focused. Work on a task-specific branch and do not mix unrelated generated or reference files.

Pull requests should explain the layout problem, implementation choice, affected commands, and test commands run. Include before/after screenshots or cropped PDF comparisons for visible typesetting changes, and note any compatibility or version-number updates.
