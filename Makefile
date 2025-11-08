PROJ:=gckanbun
TEXDOCS:=\
	gckanbun-doc.tex \
	test-gckanbun.tex \
	test-prefix.tex \
	whole-vert-sample.tex

## GNU Tar
__gtar=tar
ifeq ($(shell uname),Darwin)
# gtar: install the `gnu-tar` bottle via Homebrew
__gtar=gtar
endif


.PHONY: ${PROJ}.zip ctanzip
ctanzip: ${PROJ}.zip
${PROJ}.zip: test
	git archive --format=tar --prefix=${PROJ}/ HEAD | ${__gtar} -x

## remove unpacked files
	rm -f ${PROJ}/.gitignore ${PROJ}/Makefile

## then, make archive
	zip -9 -r ${PROJ}.zip ${PROJ}/*

	rm -rf ${PROJ}
	@echo finished

.PHONY: clean
clean:
	rm -rf ${PROJ}.zip ${PROJ}
	rm -f *.aux *.log
	find . -type f -name "*~" -delete

.PHONY: distclean
distclean: clean
	rm -f $(TEXDOCS:%.tex=%.pdf)

.PHONY: test
test: distclean
	make $(TEXDOCS:%.tex=%.pdf)

test-gckanbun.pdf: test-gckanbun.tex
	# platex $(basename $<) && dvipdfmx $(basename $<)
	uplatex $(basename $<) && dvipdfmx $(basename $<)
	lualatex $(basename $<)

gckanbun-doc.pdf: gckanbun-doc.tex whole-vert-sample.pdf
ifeq ($(shell uname),Linux)
	sed -i \
		-e 's/\(\\RequirePackage\[\)hiragino-pro,\(deluxe,expert\]{luatexja-preset}\)/\1\2/' \
		-e 's/HiraMinPro-W3/HaranoAjiMincho-Regular/g' \
		-e 's/HiraMinPro-W6/HaranoAjiMincho-Bold/g' \
		-e 's/HiraKakuPro-W3/HaranoAjiGothic-Regular/g' \
		-e 's/HiraKakuPro-W6/HaranoAjiGothic-Bold/g' \
		-e 's/HiraKakuStd-W8/HaranoAjiGothic-Heavy/g' \
		-e 's/HiraMaruPro-W4/HaranoAjiGothic-Medium/g' \
		$<
endif
	lualatex $(basename $<)
	lualatex $(basename $<)

%.pdf: %.tex
	lualatex $<
