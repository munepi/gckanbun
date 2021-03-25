gckanbun.pdf: gckanbun.tex
	lualatex gckanbun

gckanbun.zip: clean
	git archive --format=tar --prefix=gckanbun/ HEAD | gtar -x

	## remove unpacked files
	rm -f gckanbun/.gitignore gckanbun/Makefile

	## then, now just make archive
	zip -9 -r gckanbun.zip gckanbun/*

	rm -rf gckanbun
	@echo finished

test-gckanbun.pdf:
	# platex test-gckanbun && dvipdfmx test-gckanbun
	uplatex test-gckanbun && dvipdfmx test-gckanbun
	lualatex test-gckanbun

clean:
	rm -rf gckanbun.zip gckanbun
	rm -f *.aux *.log
	find . -type f -name "*~" -delete

.PHONY: gckanbun.zip
