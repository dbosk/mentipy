LATEXFLAGS += -shell-escape

.PHONY: all weave clean distclean
all: mentipy.pdf

weave: mentipy.tex

../src/mentipy/mentipy.tex: ../src/mentipy/mentipy.nw

../%::
	${MAKE} -C $(dir $@) $(notdir $@)

mentipy.pdf: mentipy.tex ../src/mentipy/mentipy.tex
mentipy.pdf: bibliography.bib preamble.tex

.PHONY: clean
clean:
	${RM} mentipy.tex mentipy.pdf

.PHONY: distclean
distclean:

INCLUDE_MAKEFILES = ../makefiles
include ${INCLUDE_MAKEFILES}/noweb.mk
include ${INCLUDE_MAKEFILES}/tex.mk
