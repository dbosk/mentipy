NOTANGLEFLAGS.py=

MODULES+=	__init__.py mentipy.tex

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
