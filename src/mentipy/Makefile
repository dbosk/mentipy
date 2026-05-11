NOTANGLEFLAGS.py=
NOTANGLE.md=notangle -R"[[$(notdir $@)]]" $(filter %.nw,$^) | ${CPIF} $@ && noroots $(filter %.nw,$^)

MODULES+= \
	__init__.py \
	cli.py \
	cli.tex \
	latex.py \
	latex.tex \
	mentipy.tex \
	network.py \
	network.tex \
	public.py \
	public.tex \
	qr.py \
	qr.tex \
	questions.py \
	questions.tex \
	server.py \
	server.tex \
	store.py \
	store.tex \
	tutorials/01-authoring-paths.md \
	tutorials/02-question-kinds.md \
	tutorials/03-layout-and-environment.md \
	tutorials/04-respondent-urls.md \
	tutorials/05-serving-and-publication.md

.PHONY: all
all: ${MODULES}

__init__.py: mentipy.nw
	${NOTANGLE.py}


tutorials:
	mkdir -p $@


tutorials/%.md: tutorials.nw | tutorials
	${NOTANGLE.md}


.PHONY: clean
clean:
	${RM} ${MODULES}


INCLUDE_MAKEFILES=../../makefiles
include ${INCLUDE_MAKEFILES}/tex.mk
include ${INCLUDE_MAKEFILES}/noweb.mk
