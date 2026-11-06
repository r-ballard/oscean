# Building Oscean

Use Bash, Git, GCC, GNU Make, awk, GNU grep (with PCRE support) and sha256sum. No WSL is required.
The scripts invoke the upstream makefile unchanged. `make run` rewrites generated
`site/`, `links/`, `docs/index.html`, `etc/index.html` and REPL assets. Use a clean
checkout or a disposable clone; do not mix a build with uncommitted content edits.

## Windows x64

Install [MSYS2](https://www.msys2.org/) at `C:\msys64`. Open **MSYS2 MSYS**
from the Start menu (the GCC package below targets the MSYS runtime):

```sh
pacman -Syu
# If instructed to close the terminal, reopen MSYS2 MSYS and repeat the update.
pacman -S --needed gcc make
# Reuse Git for Windows, already installed on this machine:
export PATH="/c/Program Files/Git/cmd:$PATH"
git -c core.autocrlf=false clone https://github.com/r-ballard/oscean.git
cd oscean
bash scripts/build.sh
```

Alternatively install MSYS Git with `pacman -S git` and omit the PATH export.
The CLI depends on `msys-2.0.dll`; launch it in MSYS2, rather than treating it
as a standalone Windows executable. Global Windows PATH changes are unnecessary.
MSVC cannot compile this Unix file API implementation unchanged.

Verified locally: GCC 16.2.0-1, Make 4.4.1-3, msys2-runtime 3.6.12-1.
These are recorded prerequisite versions, not a frozen MSYS2 package repository.

## Linux

On Ubuntu/Debian:

```sh
sudo apt-get update
sudo apt-get install --yes build-essential git gawk python3
git clone https://github.com/r-ballard/oscean.git
cd oscean
bash scripts/build.sh
python3 scripts/check-output.py
```

## Pinned tools

`bash scripts/bootstrap.sh` creates an ignored `.toolchain/` cache:

- CLI source: https://git.sr.ht/~rabbits/uxncli at
  `8d8bb97c33e79903640b4d18b2f16e04f9e0f61c`.
- Compile: `gcc -DNDEBUG -O3 -g0 -s src/uxncli.c -o <cache>/bin/uxncli`
  (`.exe` suffix on MSYS2).
- Assembler: the repository's `etc/drifblim.rom.txt`, decoded from hex.
  Decoded SHA256: `79b8d946cfacf8875b76c9d9fcf025c57138b12b69c2a75650a4a41954eda37a`.

Bootstrap verifies the checksum, checks out the exact CLI revision, rejects tracked
CLI source edits, and recompiles the CLI. Initial bootstrap needs network access;
a populated cache can be reused offline. Compiler versions may affect binary hashes.

## LF line endings

`.gitattributes` enforces LF for text in new checkouts. The build refuses CRLF
inputs before generating the site: otherwise names such as `home` gain a hidden
carriage return and fail to resolve. Adding attributes does not repair an existing
working tree automatically. Keep any personal edits safe, then make a fresh clone
with `git -c core.autocrlf=false clone ...`; do not blindly reset a working checkout.

## Verification and provenance

The baseline upstream commit is `21b90a19f63ad92b42d8bc75e8a4057f43f1dc27`.
On Windows it built successfully with the tools above: 540 site files and two
parseable RSS feeds. Upstream emits orphan/hidden content warnings and circular
index dependency warnings; these do not by themselves fail the build.

Run `python3 scripts/check-output.py` after building (Python 3 is needed only for
this additional check). CI uses the same build entry point and this verifier.
Inspect `site/home.html` in a browser as well. No script invokes the `push` target
or deploys the site.
