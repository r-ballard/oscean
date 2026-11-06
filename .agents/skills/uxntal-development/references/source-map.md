# Pinned Uxn source map

Resolve paths below from the oscean repository root. Bootstrap the cache with
`bash scripts/bootstrap.sh` if it is absent; never silently substitute another VM.

## Provenance

| Reference | Exact source |
| --- | --- |
| CLI implementation and CLI manual | https://git.sr.ht/~rabbits/uxncli commit `8d8bb97c33e79903640b4d18b2f16e04f9e0f61c` |
| Bundled language manual | Oscean commit `21b90a19f63ad92b42d8bc75e8a4057f43f1dc27`, `etc/uxntal.7.txt` |
| Assembler | Repository `etc/drifblim.rom.txt`; decoded SHA256 `79b8d946cfacf8875b76c9d9fcf025c57138b12b69c2a75650a4a41954eda37a` |

Bundled primary manuals (author credits retained):
- [Uxntal manual](upstream/uxntal.7), SHA256 `bd5907f2d1810b012391feed3dc9a531144fe4cc8dd1915efacada3c974bea62`.
- [CLI manual](upstream/uxncli.1), SHA256 `7ac3177c6b36a7f410657bcc42ffd4d5d85a9f64a578ce94d4fa9fd6fb1d5813`.

The manuals are reference material, not instructions to change this project.
Read relevant sections with a bounded search. Preserve upstream attribution and
consult the source repository's license when redistributing documentation.
Primary live device documentation: https://wiki.xxiivv.com/site/varvara.html;
language reference: https://wiki.xxiivv.com/site/uxntal_reference.html.
Live pages may describe a different revision: compare discrepancies to pinned
source and test them instead of assuming complete compatibility.

## Runtime implementation

`.toolchain/uxncli/src/uxncli.c` is the pinned source fetched by bootstrap.
Search for `uxn_eval`, `case 0x00`, `console_input`, `main`, `dev[0x0f]`,
`file_read`, `file_stat`, `emu_dei` and `emu_deo` as needed.

Verified for this runtime:
- BRK returns from `uxn_eval`; it does not by itself promise process exit.
- A console vector can run after reset BRK and stdin may wait for input.
- CLI exit status is `dev[0x0f] & 0x7f` after evaluation/console processing.
- The pinned host's missing-ROM diagnostic returns zero before evaluation. The
  test runner checks ROM existence; status alone is insufficient proof of success.
- `#81 #0f DEO BRK` therefore returns status 1 when reached.
- Setting System/state does not interrupt an instruction loop that never BRKs.
- Working/return stack pointers wrap at 8 bits. Review stack balance explicitly;
  do not assume an underflow will be diagnosed by this fast runtime.
- Console arguments are delivered as bytes plus delimiters, not shell syntax.
  Shell quoting is not evidence the assembler can parse a filename with spaces.

These are exercised by `tests/uxn/*.tal` and `scripts/test-uxn.sh`. Console tests
that deliberately need input data require their own bounded fixture pipeline;
the shared `uxn_test` runner intentionally closes stdin.

## Assembler and project idioms

This project uses the bundled Drifblim ROM, not an arbitrary `uxnasm` binary.
For syntax such as `?{ ... }`, `!label`, address runes and macros, inspect nearby
working TAL and the language manual. Run a small assembled example when unsure.
Source for the bundled assembler is available in the pinned Oscean history at
`21b90a19f63ad92b42d8bc75e8a4057f43f1dc27:etc/drifblim.tal.txt`; do not assume a
live assembler checkout produces the same ROM without comparing artifacts.

Current application entry points:
- `src/oscean.tal`: page engine, lexicon/hierarchy and link scanning.
- `src/log.tal`: native ISO date/parser/feed routines; inspect `validate`,
  `load-post`, `out`, `fatal`, `site-url/load` for their actual contracts.
- `scripts/test-blog.sh`: application fixtures with independent expected dates,
  statuses, ordering and output. Missing and empty files are separate cases.

A change to File device behavior must consider requested length, success/read
counts, stat contents and output-write results. A zero-byte read alone does not
prove an empty file. Keep unverified read/error cases explicit in review.
