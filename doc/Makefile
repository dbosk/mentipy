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

# The manual \input{}s the woven .tex of every module (see the \input list
# in mentipy.nw), so the PDF must rebuild when any module source changes,
# not only the package facade.  Keep this list in sync with that \input list;
# each entry is built on demand by the ../%:: delegation rule above.
MODULE_TEX = \
	../src/mentipy/mentipy.tex \
	../src/mentipy/questions.tex \
	../src/mentipy/qr.tex \
	../src/mentipy/store.tex \
	../src/mentipy/venv.tex \
	../src/mentipy/network.tex \
	../src/mentipy/latex.tex \
	../src/mentipy/server.tex \
	../src/mentipy/public.tex \
	../src/mentipy/cli.tex \
	../src/mentipy/tutorials.tex

mentipy.pdf: ${TEX_OUTDIR}/mentipy-obj
mentipy.pdf: mentipy.tex ${MODULE_TEX}
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
