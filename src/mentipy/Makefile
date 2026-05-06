NOTANGLEFLAGS.py=

MODULES+= \
	__init__.py \
	cli.py \
	cli.tex \
	latex.py \
	latex.tex \
	mentipy.tex \
	public.py \
	public.tex \
	qr.py \
	qr.tex \
	questions.py \
	questions.tex \
	server.py \
	server.tex \
	store.py \
	store.tex

.PHONY: all
all: ${MODULES}

__init__.py: mentipy.nw
	${NOTANGLE.py}


.PHONY: clean
clean:
	${RM} ${MODULES}


INCLUDE_MAKEFILES=../../makefiles
include ${INCLUDE_MAKEFILES}/tex.mk
include ${INCLUDE_MAKEFILES}/noweb.mk
