# .latexmkrc for the gckanbun package
# Recommended engine: LuaLaTeX (see CLAUDE.md / documentation).

# Build with LuaLaTeX directly to PDF.
$pdf_mode = 4;   # 4 = lualatex
$lualatex = 'lualatex -synctex=1 -interaction=nonstopmode -file-line-error %O %S';

# Extra auxiliary extensions removed by `latexmk -c`.
$clean_ext = 'listing toc out ltjruby synctex.gz fls fdb_latexmk';
