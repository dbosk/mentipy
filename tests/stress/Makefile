# Makefile for the stress test of Mentipy's answers
#
# `make stress` at the root of the repository runs it, and that is the only way
# it gets run: nothing in tests/Makefile or in a plain pytest reaches this
# directory.  See race.nw for why.

LATEXFLAGS += -shell-escape

.PHONY: all
all: race.py

race.py: race.nw
	${NOTANGLE.py}

# race.nw is a whole document with its own preamble, so it is woven as a fragment
# and typeset as it is, not by noweb.mk's rule that writes a preamble around it.
race.tex: race.nw
	${NOWEAVE.tex}

race.pdf: race.tex
	${PDFLATEX} ${LATEXFLAGS} $<

.PHONY: clean
clean:
	${RM} race.py race.tex race.pdf
	${RM} race.aux race.fdb_latexmk race.fls race.log race.out race.toc
	${RM} _*.data.minted
	${RM} -R _minted _minted-race


INCLUDE_MAKEFILES=../../makefiles
include ${INCLUDE_MAKEFILES}/noweb.mk
