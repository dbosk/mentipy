SUBDIR_GOALS=	all clean distclean

SUBDIR+=		src/mentipy
SUBDIR+=		tests
SUBDIR+=		doc

version=$(shell sed -n 's/^ *version *= *\"\([^\"]\+\)\"/\1/p' pyproject.toml)


.PHONY: all
all: compile doc/mentipy.pdf test

.PHONY: test
test: compile
	${MAKE} -C tests test

.PHONY: install
install: compile
	pipx install .

.PHONY: compile
compile:
	${MAKE} -C src/mentipy all
	poetry build

.PHONY: publish publish-github publish-pypi
publish: publish-github

publish-github: doc/mentipy.pdf
	git push
	gh release create -t v${version} v${version} doc/mentipy.pdf

doc/mentipy.pdf:
	${MAKE} -C $(dir $@) $(notdir $@)

publish-pypi: compile
	poetry publish


.PHONY: clean
clean:

.PHONY: distclean
distclean:
	${RM} -R build dist mentipy.egg-info src/mentipy.egg-info


INCLUDE_MAKEFILES=makefiles
include ${INCLUDE_MAKEFILES}/subdir.mk
