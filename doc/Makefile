LATEXFLAGS += -shell-escape
TEX_PYTHONTEX = yes
PYTHONTEXFLAGS = --interpreter python:"poetry run python3"
TEX_OUTDIR = ltxobj

.PHONY: all weave clean distclean
all: mentipy.pdf

weave: mentipy.tex

../src/mentipy/mentipy.tex: ../src/mentipy/mentipy.nw

../%::
	${MAKE} -C $(dir $@) $(notdir $@)

${TEX_OUTDIR}/build:
	${MKDIR} ${TEX_OUTDIR}
	-${RM} $@
	${LN} -s ../build $@

mentipy.pdf: ${TEX_OUTDIR}/build
mentipy.pdf: mentipy.tex ../src/mentipy/mentipy.tex
mentipy.pdf: bibliography.bib preamble.tex

mentipy.pdf: $(wildcard build/*.pdf_tex)
mentipy.pdf: $(wildcard build/*.pdf)

.PHONY: serve
serve: mentipy.pdf
	mentipy serve --public --results &
	pdflatex mentipy.tex

.PHONY: clean
clean:
	${RM} mentipy.tex mentipy.pdf
	${RM} -R build

.PHONY: distclean
distclean:

INCLUDE_MAKEFILES = ../makefiles
include ${INCLUDE_MAKEFILES}/noweb.mk
include ${INCLUDE_MAKEFILES}/tex.mk
