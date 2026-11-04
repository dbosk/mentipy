# mentipy

`mentipy` is a lightweight, self-hosted classroom-polling library for LaTeX
presentations. It generates LaTeX snippets and QR codes for audience questions,
then runs a local HTTP server that collects responses in a local JSON store.

It is meant for lectures where you want Mentimeter-style interaction without a
cloud service: put polls in the lecture source, compile the slides or handout,
serve the poll locally, and let students answer by scanning the QR code.

## Installation

Mentipy needs Python 3.11 or newer. Install it with
[uv](https://docs.astral.sh/uv/getting-started/installation/), which brings
that Python along even when the system runs an older one:

```sh
uv tool install --python 3.11 mentipy
```

uv downloads Python 3.11 if the machine lacks it and keeps it with `mentipy` in
an environment of their own, so the system Python stays as it is. Keep
`--python 3.11`: on a system with Python 3.10, uv would otherwise settle for the
last Mentipy release that runs there. If pipx already has `mentipy`, run
`pipx uninstall mentipy` first, or uv refuses to replace the executable.

The optional features are extras, and `uv tool upgrade mentipy` later keeps both
them and the Python. Name all the extras you want, because installing again
replaces the earlier choice:

```sh
uv tool install --python 3.11 'mentipy[public,wordcloud]'
```

PythonTeX imports Mentipy from the document build's own Python, so a deck also
needs a virtual environment. `mentipy init` creates `./.venv` on the Python that
Mentipy itself runs on, which is 3.11 after the commands above, whatever
`python3` is on the system. It reuses an existing `.venv`, so delete one made
with an older Python first. It installs Mentipy without extras, so run
`mentipy serve` outside an activated `.venv` when you need them.

To make that environment without installing the tool, use `uv venv`. `--seed`
adds pip, which `mentipy init` calls to install into it:

```sh
uv venv --seed --python 3.11 .venv
uv pip install --python .venv/bin/python mentipy
```

### Upgrading from a version before 1.0

Mentipy 1.0 keeps each setting as a key of its own in the config file:
`mentipy config base_url --set ...` stores `base_url`. Earlier versions kept them
in a `mentipy` section, written `mentipy.base_url`, and 1.0 neither reads nor
converts that section. So a deck that relied on a configured address gets the LAN
address instead, without a warning, until the value is set again.
`mentipy config mentipy` lists the old values; set the ones you still want under
their new names. The old spelling is still accepted by the command, but it only
writes to the old section. The reverse also holds: a value once stored under a
short name, which earlier versions ignored, now takes effect, so look through what
`mentipy config` lists. That command shows only what the file holds, and its tab
completion offers only keys already set, so a leftover section shows up there as
`mentipy.base_url`; `mentipy latex` lists the keys that exist.

A deck's `.venv` has its own Mentipy, which reads the same file, and the version
there decides what a build sees: a venv older than 1.0 reads only the old section,
and 1.0 reads only the new keys. Writing a new key leaves the old section as it
was, so keep the section until every deck is on 1.0, which `mentipy init` in the
deck does. `mentipy config mentipy --set ""` removes it afterwards.

## Basic Workflow

1. Render questions from PythonTeX or from the `mentipy render` CLI.
2. Compile the LaTeX document so the generated QR codes are embedded.
3. Start the polling server with `mentipy serve --store ./mentipy.json`.
4. Let respondents scan the QR codes and answer the questions.
5. Watch or export answers with `mentipy watch`, `mentipy export`, or the live
   results page.

The examples below keep the questions in `./mentipy.json`, the answers beside it
in `./mentipy-answers.jsonl`, and write QR artifacts in `mentipy-obj/`.

## Authoring a Poll

Both authoring paths produce the same kind of LaTeX fragment. Use the Python
helpers when your document build already runs PythonTeX; use the CLI when you
want to inspect or redirect the generated LaTeX yourself.

PythonTeX-style authoring:

```python
from mentipy.latex import mc

print(
    mc(
        "How confident do you feel about the course goals?",
        ["Very confident", "Somewhat confident", "Not yet"],
        base_url="http://localhost:8080",
        qr_dir="mentipy-obj",
        layout="article+qr",
    )
)
```

The matching CLI command:

```sh
mentipy render mc "How confident do you feel about the course goals?" \
  "Very confident" "Somewhat confident" "Not yet" \
  --base-url http://localhost:8080 \
  --qr-dir mentipy-obj \
  --layout article+qr
```

The CLI prints LaTeX to standard output, so you can redirect it into a file:

```sh
mentipy render mc "Ready for the next section?" \
  "Yes" "Need a recap" "Not yet" > poll.tex
```

## Question Kinds

Use the question kind that matches the response shape you want to collect.

| Response shape | Python helper | CLI command |
| --- | --- | --- |
| One listed option | `mc(text, options)` | `mentipy render mc TEXT OPTION...` |
| Several listed options | `mc(text, options, multi=True)` | `mentipy render mc --multi TEXT OPTION...` |
| Free text | `open_text(text)` | `mentipy render open TEXT` |
| Numeric scale | `scale(text, low=1, high=5)` | `mentipy render scale TEXT --low 1 --high 5` |
| Word cloud | `word_cloud(text)` | `mentipy render word-cloud TEXT` |

Open-text questions can also collect uploaded files. Pass `fence="python"` or
`--fence python` when uploaded code should be rendered as a language-tagged
Markdown code block on the results page.

Word-cloud questions default to `render="svg"`. Installing
`mentipy[wordcloud]` lets that mode use the optional `wordcloud` layout engine;
without it, `mentipy` falls back to its built-in SVG renderer.

## Layout and LaTeX Integration

Rendering options control the LaTeX wrapper without changing the poll identity.

| Option | Purpose |
| --- | --- |
| `layout="slide"` / `--layout slide` | Render for presentation slides. |
| `layout="article"` / `--layout article` | Render a flat, transparent article-style question: the prompt alone, in the running text's weight; no options, form instructions, limits or QR. |
| `layout="article+qr"` / `--layout article+qr` | Include the QR image beside the article-style question. |
| `layout="auto"` / `--layout auto` | Let `mentipy` choose from the surrounding context. |
| `environment="exercise"` / `--env exercise` | Wrap the question in an existing LaTeX environment. |
| `show_url=False` / `--no-url` | Suppress the printed respondent URL when the layout supports it. |

The QR layouts print the respondent URL through the LaTeX macro
`\mentipyqrcaption{URL}` (default `\footnotesize\ttfamily`). Redefine it in
your preamble to change the caption's size or allow line breaks, for example
`\newcommand{\mentipyqrcaption}[1]{{\tiny\url{#1}}}`. Do not replace the
sidecar `\input` with your own text: that copy is frozen at compile time and
stops following `mentipy serve`.

The named LaTeX environment must already be defined by your document class or
preamble. For example, a lecture note template can use `environment="exercise"`
to reuse its existing exercise styling and counters.

## Serving Polls

After the questions have been registered during rendering, start the local
server:

```sh
mentipy serve --store ./mentipy.json
```

For a lecture, `mentipy present` starts the same server and, in the same
terminal, follows the question the lecturer opens (as a bare
`mentipy watch` does, see below). It takes all of `serve`'s options and
`watch`'s `--interval`, `--window` and `--pin-heat`. It reprints the
start-up lines (address, QR warning, admin link) and a count of server
warnings at the top whenever it redraws, that is on every new question
and every refresh of a tally; an open question's answers are appended
below instead, so there they can scroll away. Keep that terminal off
the projector:

```sh
mentipy present --store ./mentipy.json
mentipy present --store ./mentipy.json --public ssh
```

Once the server listens, `present` also opens its admin index in your
browser and goes straight on to the watch. It does so only when the
server binds every interface or a loopback address (or under
`--public ssh`, with the admin token): a server bound to one other
address would refuse the browser, and `present` says so instead. The
command depends on the platform: `xdg-open` on Linux and other Unix
systems, `open` on macOS and `explorer` on Windows. Set
`open_command` to use another (a `{url}` in it marks where the
URL goes, otherwise it is appended; on Windows a path may be quoted),
or to an empty value or `none` to never open the browser on that
machine. Pass `--open-with CMD` for one run, or `--no-open` to skip
the step. Under `--public ssh` the URL with the admin token passes
through the opener's command line, so on a shared machine use
`--no-open`:

```sh
mentipy config open_command --set "firefox --new-window"
mentipy present --store ./mentipy.json --no-open
```

The QR codes carry the server's address, so the slides are best built once the
server is up. `--slides-command CMD`, or the setting `slides_command`,
runs a shell command after the server has started, in the directory you started
`present` in. Nothing runs if neither is set. `present` doesn't wait for it, and
its output goes to `slides-command.log` in the QR directory beside the store.
When you restart `present` during a lecture, add `--no-slides`, or it opens a
second viewer:

```sh
mentipy config slides_command --set "make slides.pdf && pdfpc -w both slides.pdf"
mentipy present --slides-command "make slides-intro.pdf && pdfpc -w both slides-intro.pdf"
```

For this to pick up a new address, two things must hold:

- `make` must know the PDF depends on the QR codes, or it finds the PDF up to date
  and the viewer shows the old ones. A deck's Makefile says so with
  `slides.pdf: $(wildcard mentipy-obj/Q-*.pdf_tex)`.
- The Mentipy in the deck's own `.venv` must be 1.0 or newer, because that is the
  one writing the QR codes in a build. An older one writes the configured address
  whatever the server serves. `mentipy init` in the deck upgrades it.

A non-zero exit status of the command shows in the status line, and under an open
question below the answers. Join the steps with `&&`, since `make x; pdfpc x` or a
trailing `&` hides the status.

A zero means the command finished and, with the shared `makefiles/tex.mk`, that a
PDF exists. It doesn't mean the PDF is right. In a Beamer deck:

- A fatal LaTeX error, such as a missing package or `\input`, normally shows as a
  failure and the viewer doesn't open. **It also deletes the PDF, including a good
  one from an earlier build, so `present` rebuilding minutes before class can leave
  you with no slides. Keep a copy.**
- A `pycode` exception, or an undefined macro under `-interaction=nonstopmode`,
  shows no failure. The viewer opens a rewritten PDF whose poll frames come from an
  earlier PythonTeX run, or are empty.
- With an earlier PDF, a missing `\documentclass` shows no failure, and the viewer
  opens that PDF.

While the command runs, `present` also reads this run's part of the log. At a line
starting `Latexmk: Errors` or `Collected error summary` it adds `Slides may have
failed` to the status line, even with the viewer open. That is an extra warning
keyed to those strings, never a verdict: without it the build may still have
failed. It comes only from a build that ran, so a restart that `make` finds up to
date gets a zero, opens the PDF and loses an earlier warning. So if the slides look
wrong, read `slides-command.log`, where the errors are and where each run has a
heading with the time.

A deck's Makefile can get `latexmk`'s real status, by setting this before its
`include`:

```make
COMPILE.tex = ${PDFLATEX} ${LATEXFLAGS} -output-directory=${TEX_OUTDIR} $<
```

A `pycode` exception or a missing `\documentclass` then shows as a failure and the
viewer doesn't open. The failed build still rewrites the PDF after a `pycode`
exception, so after an earlier good build a restart on the same port finds `make`
up to date, gets a zero and opens that PDF, until you change a source or `touch`
it. Without an earlier good build there is no `slides.pdf` link, so `make` runs
again and it stays a failure, and another port rebuilds too. Don't add
`.DELETE_ON_ERROR:`, which deletes both the PDF and its link.

Ctrl-C leaves the command running, so the viewer stays open. The status line names
its pid, and `present` says on its way out if it's still running. That's normal
with a viewer open. A build that's still running is another matter: the served
address goes when `present` stops, so that build writes the configured address
into the QR codes. To recover, stop it with `kill -- -PID`, since a plain `kill` leaves
`make` running, and start `present` again with the command. `--no-slides` corrects
the QR files but not the PDF on the screen, and starting the command again without
stopping the old one gives two builds and two viewers.

Use `--results` when respondents should land on the live results page after
submitting an answer:

```sh
mentipy serve --store ./mentipy.json --results
```

The server's root URL is your index of the questions, on the lecture machine
or with the admin token. After a rebuild that dropped or edited questions it
has two sections: `Current questions`, the deck as last built, and `Old
questions`, which keep their answers, links and QR codes. The row of the
question the lecture is on has a toned background. A question the deck asks
twice has one row, at its last place, so a deck A, B, C, A, D lists B first.
Next and Previous have the same one stop per question: in X, Y, A, B, C, A they
go from Y straight to B, so for a poll before and after an explanation, open
its first ask from the index. A deck built with `mentipy render` needs
`--new-run` on its first question to get the sections: without it a rebuild
continues the old chain, so old questions are listed as current, often with no
headings at all. Each render is its own process, so a deck built that way that
asks a question twice loses the questions before its first place, with or
without `--new-run`: they have no Next link and are listed as old.

Terminal helpers use question hash prefixes. List registered questions first,
then watch or export one question by prefix:

```sh
mentipy list --store ./mentipy.json
mentipy watch f379 --store ./mentipy.json
mentipy export f379 --format csv --store ./mentipy.json
```

During a lecture, a bare `mentipy watch` (no prefix) follows the
question the lecturer has opened on the running server, and switches
whenever Next or Skip moves the lecture on. Start it once, beside
`mentipy serve`, with the same store. It asks the server for `/active`,
at the `host` and `port` settings (its loopback address when the server binds
every interface), unless `--server` names another address.
It needs no admin rights, and it keeps retrying while the server is not
running:

```sh
mentipy watch --store ./mentipy.json
mentipy watch --store ./mentipy.json --server http://localhost:9000
```

## Respondent URLs and QR Codes

You can pass `base_url` / `--base-url` while rendering, or store a default:

```sh
mentipy config base_url --set http://polls.example.org:8080
```

Use an address the students' phones can reach. The QR codes then use it as
written, whatever `--port` the server runs on. To go back to the LAN address,
run `mentipy config base_url --set auto`.

If no base URL is configured, `mentipy` resolves the current LAN address from
the serving port. Because QR codes are generated when the document compiles,
`mentipy serve` may regenerate remembered QR images and ask you to recompile the
slides so the PDF embeds the updated codes.
While the server runs, builds use its address, so you can start the server and
then compile, even after editing a question, without changing the configuration.
An explicit `base_url=` in the deck still wins. Stopping the server ends this,
whether with Ctrl-C, a plain `kill` or by closing its terminal (on Windows, only
Ctrl-C): the QR codes keep its address until PythonTeX next regenerates them, which
then uses the configuration again. After `kill -9`, Ctrl-\ or a power cut, builds
keep using the dead address, without a warning, until a server starts again or you
remove `mentipy-obj/.served-base-url`.

For public access, `mentipy serve` can expose the local server in two modes:

```sh
mentipy serve --store ./mentipy.json --public upnp
mentipy config ssh_tunnel --set user@example.org:8080
mentipy serve --store ./mentipy.json --public ssh
```

The UPnP mode requires the optional `mentipy[public]` dependency and a router
that accepts temporary port mappings. The SSH mode uses an SSH reverse tunnel;
the remote SSH server must allow the forwarded port to be reached publicly.

The polling server is intentionally simple. Anyone with the URL can submit
answers, and with `--results` they can view the live tally. Treat a public poll
URL like a shared room link, not like a private admin interface.

## Where the Answers Are

The answers go in a log beside the store, named after it: `mentipy.json` gets
`mentipy-answers.jsonl`, one answer per line. Nothing ever rewrites the log, so
a build running during a lecture cannot lose an answer, whichever Mentipy the
build uses, and a stopped build cannot delay one. The server thanks a student
only after the answer was sent to the disk. A server that cannot write the log
does not start, and if writing fails during a lecture the student is told the
answer was not saved and to tell you. To move a store to another machine,
copy the store, its log and `mentipy-images/`. To start a deck over, delete the
store and its log: with the log left behind, a question registered again gets
its old answers back.

The names of the log and the images directory follow the store's, so rename them
together: `lecture1.json` needs `lecture1-answers.jsonl` and `lecture1-images/`.
With only the store renamed, it shows none of the answers in the old log, with no
warning, and the next answer starts a second log. Moving the log back to its
name recovers them, though the two logs have to be joined by hand.

The log holds what students wrote, so decide what git does with it:

- A repository that ignores its store should ignore the log too: add
  `mentipy-answers.jsonl` to `.gitignore`. `mentipy serve` and `mentipy present`
  warn when git ignores the store but not the log, since `git add .` would
  otherwise commit the answers.
- A repository that commits its store to keep the answers now commits two files:
  `git add mentipy-answers.jsonl`. Until then `git commit -a` leaves the answers
  out and `git clean -fd` deletes the only copy, so `mentipy serve` and
  `mentipy present` warn at the start when git tracks the store but not the log.
  The log is well suited to being committed, as a lecture shows up as added lines
  and the store's bytes no longer change with the answers. Set
  `mentipy-answers.jsonl merge=union` in `.gitattributes` so that answers added on
  two branches merge without a conflict. That line covers only the default name:
  a store called `lecture1.json` needs its own, or `*-answers.jsonl merge=union`.

Answers recorded by an older version stay in `mentipy.json` and are read from there.
An older Mentipy cannot read the log, so upgrade it everywhere, the `.venv` of each
deck included. On a newer store an older `mentipy serve`, `view` and `watch` show
none of the answers in the log, so `Responses: 0` on a new store, and an older
`mentipy export` writes only a CSV header, which overwrites a good export if sent
to the same file. No answer is harmed: what an older `serve` records goes in
`mentipy.json`, and the new version reads both.

## Discovering Commands

Useful entry points while learning the tool:

```sh
mentipy render --help
python3 -m pydoc mentipy.latex
mentipy tutorial list
mentipy tutorial run using-tutorials
```

The tutorial sequence mirrors the usage introduction: authoring paths, question
kinds, layout and environment choices, respondent URLs, and serving/publication.
