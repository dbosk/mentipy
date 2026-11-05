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

# Real servers, builds and signals for some minutes, only on request: not part of
# `all` or `test`.  Pass options in STRESSFLAGS, for example
# make stress STRESSFLAGS="builds kill-server --seconds 10"
.PHONY: stress
stress:
	${MAKE} -C src/mentipy all
	${MAKE} -C tests/stress race.py
	poetry run python tests/stress/race.py ${STRESSFLAGS}

.PHONY: install
install: compile
	uv tool install --force --python 3.11 .

.PHONY: compile
compile:
	${MAKE} -C src/mentipy all
	poetry build

.PHONY: publish publish-github publish-pypi
publish: publish-github publish-pypi

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
