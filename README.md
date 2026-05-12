# mentipy

`mentipy` is a lightweight, self-hosted classroom-polling library for LaTeX
presentations. It generates LaTeX snippets and QR codes for audience questions,
then runs a local HTTP server that collects responses in a local JSON store.

It is meant for lectures where you want Mentimeter-style interaction without a
cloud service: put polls in the lecture source, compile the slides or handout,
serve the poll locally, and let students answer by scanning the QR code.

## Basic Workflow

1. Render questions from PythonTeX or from the `mentipy render` CLI.
2. Compile the LaTeX document so the generated QR codes are embedded.
3. Start the polling server with `mentipy serve --store ./mentipy.json`.
4. Let respondents scan the QR codes and answer the questions.
5. Watch or export answers with `mentipy watch`, `mentipy export`, or the live
   results page.

The examples below keep state in `./mentipy.json` and write QR artifacts in
`mentipy-obj/`.

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

Open-text questions can also collect uploaded files. Pass `fence="python"` or
`--fence python` when uploaded code should be rendered as a language-tagged
Markdown code block on the results page.

## Layout and LaTeX Integration

Rendering options control the LaTeX wrapper without changing the poll identity.

| Option | Purpose |
| --- | --- |
| `layout="slide"` / `--layout slide` | Render for presentation slides. |
| `layout="article"` / `--layout article` | Render a flat article-style question. |
| `layout="article+qr"` / `--layout article+qr` | Include the QR image beside the article-style question. |
| `layout="auto"` / `--layout auto` | Let `mentipy` choose from the surrounding context. |
| `environment="exercise"` / `--env exercise` | Wrap the question in an existing LaTeX environment. |
| `show_url=False` / `--no-url` | Suppress the printed respondent URL when the layout supports it. |

The named LaTeX environment must already be defined by your document class or
preamble. For example, a lecture note template can use `environment="exercise"`
to reuse its existing exercise styling and counters.

## Serving Polls

After the questions have been registered during rendering, start the local
server:

```sh
mentipy serve --store ./mentipy.json
```

Use `--results` when respondents should land on the live results page after
submitting an answer:

```sh
mentipy serve --store ./mentipy.json --results
```

Terminal helpers use question hash prefixes. List registered questions first,
then watch or export one question by prefix:

```sh
mentipy list --store ./mentipy.json
mentipy watch f379 --store ./mentipy.json
mentipy export f379 --format csv --store ./mentipy.json
```

## Respondent URLs and QR Codes

You can pass `base_url` / `--base-url` while rendering, or store a default:

```sh
mentipy config set base_url http://localhost:8080
```

If no base URL is configured, `mentipy` resolves the current LAN address from
the serving port. Because QR codes are generated when the document compiles,
`mentipy serve` may regenerate remembered QR images and ask you to recompile the
slides so the PDF embeds the updated codes.

For public access, `mentipy serve` can expose the local server in two modes:

```sh
mentipy serve --store ./mentipy.json --public upnp
mentipy config set ssh_tunnel user@example.org:8080
mentipy serve --store ./mentipy.json --public ssh
```

The UPnP mode requires the optional `mentipy[public]` dependency and a router
that accepts temporary port mappings. The SSH mode uses an SSH reverse tunnel;
the remote SSH server must allow the forwarded port to be reached publicly.

The polling server is intentionally simple. Anyone with the URL can submit
answers, and with `--results` they can view the live tally. Treat a public poll
URL like a shared room link, not like a private admin interface.

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
