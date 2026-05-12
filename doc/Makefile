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

${TEX_OUTDIR}/mentipy-obj:
	${MKDIR} ${TEX_OUTDIR}
	-${RM} $@
	${LN} -s ../mentipy-obj $@

mentipy.pdf: ${TEX_OUTDIR}/mentipy-obj
mentipy.pdf: mentipy.tex ../src/mentipy/mentipy.tex
mentipy.pdf: bibliography.bib preamble.tex

mentipy.pdf: $(wildcard mentipy-obj/*.pdf_tex)
mentipy.pdf: $(wildcard mentipy-obj/*.pdf)

.PHONY: serve
serve: mentipy.pdf
	mentipy serve --public --results &
	pdflatex mentipy.tex

.PHONY: clean
clean:
	${RM} mentipy.tex mentipy.pdf
	${RM} -R mentipy-obj

.PHONY: distclean
distclean:

INCLUDE_MAKEFILES = ../makefiles
include ${INCLUDE_MAKEFILES}/noweb.mk
include ${INCLUDE_MAKEFILES}/tex.mk
