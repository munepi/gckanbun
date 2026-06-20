# Makefile for the gckanbun LaTeX package.
# Recommended engine: LuaLaTeX (configured in .latexmkrc).

LATEXMK := latexmk
DOCS    := gckanbun-doc gckanbun-test gckanbun-sample gckanbun-edge-test gckanbun-edge-test-tate
PDFS    := $(addsuffix .pdf,$(DOCS))
UPTEX_TEST := gckanbun-edge-test-uptex
CTAN_ZIP := gckanbun.zip
CTAN_FILES := \
	gckanbun.sty \
	gckanbun-doc.tex gckanbun-doc.pdf \
	gckanbun-sample.tex gckanbun-sample.pdf \
	gckanbun-test.tex gckanbun-test.pdf \
	gckanbun-edge-test.tex gckanbun-edge-test.pdf \
	gckanbun-edge-test-tate.tex gckanbun-edge-test-tate.pdf \
	gckanbun-edge-test-uptex.tex gckanbun-edge-test-uptex.pdf \
	README.md LICENSE.md KNOWN_ISSUES.md \
	CTAN-ANNOUNCEMENT.txt CTAN-SUBMISSION.txt \
	Makefile .latexmkrc

.PHONY: all doc test sample edge-test edge-test-tate edge-test-uptex zip clean distclean

# Build everything.
all: $(PDFS)

doc:  gckanbun-doc.pdf
test: gckanbun-test.pdf
sample: gckanbun-sample.pdf
edge-test: gckanbun-edge-test.pdf
edge-test-tate: gckanbun-edge-test-tate.pdf
edge-test-uptex:
	uplatex -interaction=nonstopmode -file-line-error $(UPTEX_TEST).tex
	uplatex -interaction=nonstopmode -file-line-error $(UPTEX_TEST).tex
	dvipdfmx $(UPTEX_TEST).dvi
zip: $(CTAN_ZIP)

gckanbun-doc.pdf: gckanbun-test.pdf

# Each PDF depends on its source and on the package.
%.pdf: %.tex gckanbun.sty
	$(LATEXMK) $<

# Build the flat archive submitted to CTAN. Development-only files and
# reference trees under ref/ are intentionally excluded.
$(CTAN_ZIP): $(CTAN_FILES)
	$(RM) $@
	zip -9 $@ $(CTAN_FILES)

# Remove auxiliary files, keep the PDFs.
clean:
	$(LATEXMK) -c
	$(RM) *.aux *.log *.out *.toc *.listing *.ltjruby *.dvi

# Also remove generated PDFs and the CTAN archive.
distclean:
	$(LATEXMK) -C
	$(RM) $(PDFS) $(UPTEX_TEST).pdf $(UPTEX_TEST).dvi $(CTAN_ZIP)
