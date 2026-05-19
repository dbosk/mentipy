# Mentipy Repository Guide

## Source of truth

- This is a literate noweb project. Edit `*.nw` files in `src/mentipy/` and `doc/`; do not hand-edit generated `*.py` or `*.tex` files.
- Generated artifacts are intentionally untracked: `src/.gitignore` ignores `*.py` and `*.tex`, `tests/.gitignore` ignores generated test files, and `doc/.gitignore` ignores woven/build outputs.
- After changing a module `.nw` file, regenerate it from the matching subdirectory with `make <module>.py` and, if documentation changed, `make <module>.tex`.

## Build and test commands

- Full project build: `make` at the repo root. This runs `compile`, builds `doc/mentipy.pdf`, and then runs tests.
- Compile package outputs only: `make -C src/mentipy all`
- Run all tests: `make test` or `make -C tests test`
- Focused test file: `poetry run pytest tests/unit/test_<module>.py -q`
- Regenerate one test file after changing `src/mentipy/<module>.nw`: `make -C tests unit/test_<module>.py`
- Weave the manual without building the PDF: `make -C doc mentipy.tex`
- Build the manual PDF: `make -C doc mentipy.pdf`

## Repo layout

- `src/mentipy/*.nw`: real implementation sources.
- `src/mentipy/mentipy.nw`: package facade; re-exports the public API from the smaller modules.
- `src/mentipy/questions.nw`: frozen question models and canonical hashing input.
- `src/mentipy/store.nw`: config loading, persistent JSON store, stable prefix resolution.
- `src/mentipy/venv.nw`: local virtualenv creation, package installation, and activation snippets.
- `src/mentipy/latex.nw`: PythonTeX-facing LaTeX helpers; handles registration and QR generation side effects.
- `src/mentipy/server.nw`: standard-library threaded HTTP server and HTML results/forms.
- `src/mentipy/cli.nw`: Typer CLI; thin wrapper over store/server/LaTeX helpers.
- `src/mentipy/public.nw`: public exposure helpers for `mentipy serve` (UPnP and SSH reverse tunnels).
- `src/mentipy/qr.nw`: QR generation via `segno`.
- `tests/Makefile`: auto-discovers `<<test [[module.py]]>>` chunks in `src/**/*.nw` and tangles them into `tests/unit/test_*.py`.

## Non-obvious workflow constraints

- Tests live inside the module `.nw` files. Add or update tests there, then regenerate `tests/unit/test_*.py` via `make -C tests ...`.
- The default tangling rule runs `black` on generated Python (`makefiles/noweb.mk` sets `NOWEB_PYCODEFMT=black`). If tangling changes formatting, treat the `.nw` file as the editable source and re-run the tangle instead of editing generated Python.
- The manual uses PythonTeX with `poetry run python3` (`doc/Makefile`). If documentation examples depend on runtime code, prefer verifying with `make -C doc mentipy.tex` or `mentipy.pdf` rather than assuming plain LaTeX is enough.
- `make test` depends on `compile`, so root-level tests regenerate package outputs before running `pytest`.
- Runtime state file `mentipy.json` is ignored at the repo root. Do not commit it.

## Packaging and runtime facts

- Python requirement is `>=3.10,<4.0` (`pyproject.toml`).
- The console entrypoint is `mentipy = "mentipy.cli:main"`.
- Defaults and config keys live in `src/mentipy/store.nw`; both CLI and LaTeX helpers read settings from there.
- Optional public exposure support is packaged as `mentipy[public]`, which installs `miniupnpc` for the UPnP mode; SSH mode stays stdlib-only.
- `MENTIPY_CONFIG` overrides the config file location for tests and local runs.

## Commit hygiene for this repo

- In this repo, committing generated `src/mentipy/*.py`, `src/mentipy/*.tex`, `tests/unit/*.py`, or `doc/mentipy.tex` is almost certainly wrong. Commit the corresponding `.nw` sources instead.
