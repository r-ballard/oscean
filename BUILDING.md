# Building the wiki

Use Bash, Git, GCC, GNU Make, awk, GNU grep (PCRE support), and sha256sum.
No WSL, Python or Markdown converter is required.

## Windows x64

Install [MSYS2](https://www.msys2.org/) at `C:\msys64`. Open **MSYS2 MSYS**:

```sh
pacman -Syu
# If instructed to close the terminal, reopen MSYS2 MSYS and repeat the update.
pacman -S --needed gcc make
export PATH="/c/Program Files/Git/cmd:$PATH"
git -c core.autocrlf=false clone https://github.com/r-ballard/oscean.git
cd oscean
bash scripts/build.sh
```

The PATH line reuses Git for Windows. Alternatively install MSYS Git with
`pacman -S git` and omit it. The compiled CLI requires MSYS2's runtime DLL, so run
it from MSYS2. Global Windows PATH changes are unnecessary. MSVC cannot compile
this Unix file API implementation unchanged.

Verified prerequisites: GCC 16.2.0-1, Make 4.4.1-3, msys2-runtime 3.6.12-1.
These record the tested environment; they are not a frozen package repository.

## Linux

On Ubuntu/Debian:

```sh
sudo apt-get update
sudo apt-get install --yes build-essential git gawk
git clone https://github.com/r-ballard/oscean.git
cd oscean
bash scripts/build.sh
```

## Pinned tools and provenance

`bash scripts/bootstrap.sh` creates an ignored `.toolchain/` cache:

- CLI: https://git.sr.ht/~rabbits/uxncli at
  `8d8bb97c33e79903640b4d18b2f16e04f9e0f61c`.
- Compile: `gcc -DNDEBUG -O3 -g0 -s src/uxncli.c -o <cache>/bin/uxncli`
  (`.exe` suffix on MSYS2).
- Drifblim: decode the versioned `etc/drifblim.rom.txt` hexadecimal artifact.
  Decoded SHA256: `79b8d946cfacf8875b76c9d9fcf025c57138b12b69c2a75650a4a41954eda37a`.

Bootstrap verifies the checksum and source revision, rejects edited CLI source,
and recompiles. Initial setup needs network access; the source cache can then be
reused offline. Compiler versions can affect executable hashes.

The original Oscean baseline is `21b90a19f63ad92b42d8bc75e8a4057f43f1dc27`.
Its unchanged build was reproduced before content replacement. This fork's makefile
now runs only the page engine and adapted native blog generator; old image-diary,
listing and interactive-demo targets were removed with their content.

## Inputs, outputs and checks

Authored inputs are `src/lexicon`, body fragments in `src/htm/`, the manifest and
post sources in `src/blog/`, publication base `src/site-url.txt`, retained CSS, and original assets in `media/`.
See [AUTHORING.md](AUTHORING.md) for the content contract.

The build assembles `bin/oscean.rom` and `bin/log.rom`, generates the blog fragment
and RSS, then clears/rebuilds `site/` and its intermediate backlink data. Generated
`site/`, `links/log.xml`, `src/htm/blog.htm` and `src/htm/sitemap.htm` are ignored.
Do not hand-edit or commit them as article source.

`.gitattributes` enforces LF in fresh checkouts. The build rejects CRLF inputs
before generation, because Varvara file devices consume literal bytes. Preserve
personal edits before repairing an old checkout; a fresh clone with
`git -c core.autocrlf=false clone ...` is the safest starting point.

CI calls the same build entry point and native shell/Uxn regression checks. These
add no new runtime dependencies. Review generator diagnostics and inspect the
rendered pages, links and feed when reviewing content. No bundled push target,
upstream writes or deployment is performed by the build scripts.

The root page redirects to `site/home.html`. `src/site-url.txt` currently proposes
`https://r-ballard.github.io/oscean/` as the fork preview base for absolute RSS
links. Verify/change this before any deployment; it does not change Pages settings
or the existing production site. A clean publishing artifact and
GitHub Pages deployment remain separate roadmap steps; no production cutover
is implied by a local build.
