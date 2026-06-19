# Makefile for the gckanbun LaTeX package.
# Recommended engine: LuaLaTeX (configured in .latexmkrc).

LATEXMK := latexmk
DOCS    := gckanbun-doc gckanbun-test gckanbun-sample
PDFS    := $(addsuffix .pdf,$(DOCS))

.PHONY: all doc test sample clean distclean

# Build everything.
all: $(PDFS)

doc:  gckanbun-doc.pdf
test: gckanbun-test.pdf
sample: gckanbun-sample.pdf

# Each PDF depends on its source and on the package.
%.pdf: %.tex gckanbun.sty
	$(LATEXMK) $<

# Remove auxiliary files, keep the PDFs.
clean:
	$(LATEXMK) -c
	$(RM) *.aux *.log *.out *.toc *.listing *.ltjruby

# Also remove the generated PDFs.
distclean:
	$(LATEXMK) -C
	$(RM) $(PDFS)
