# HAR-109 verification — 2026-11-05

Implementation branch: har-109-reproducible-build.
Baseline: 21b90a19f63ad92b42d8bc75e8a4057f43f1dc27 (XXIIVV/oscean).
Implementation tested: 597ceb17c (local commit).
Fork: https://github.com/r-ballard/oscean; upstream: https://github.com/XXIIVV/oscean.

## Windows evidence

OS/architecture: Windows x64, MSYS_NT-10.0-26200; MSYS2 MSYS Bash.
GCC 16.2.0-1; GNU Make 4.4.1-3; msys2-runtime 3.6.12-1.
MSYS2 installed at C:\msys64. No WSL; no global Windows PATH changes.
Original checkout: C:\Users\russe\Documents\codex-github\oscean.
Fresh clone: C:\Users\russe\AppData\Local\Temp\har109 final clone.

Fresh clone command (PowerShell, from any directory):

    git -c core.autocrlf=false clone --no-hardlinks --branch har-109-reproducible-build C:/Users/russe/Documents/codex-github/oscean 'C:/Users/russe/AppData/Local/Temp/har109 final clone'

From that fresh clone, MSYS2 MSYS shell:

    export PATH="/c/Program Files/Git/cmd:$PATH"
    bash -n scripts/bootstrap.sh scripts/build.sh scripts/test-build-guards.sh
    bash scripts/test-build-guards.sh
    bash scripts/build.sh > build-test.log 2>&1
    bash scripts/bootstrap.sh > bootstrap-repeat.log 2>&1

All returned 0. Initial cache was absent; CLI was fetched and compiled at pinned
commit 8d8bb97c33e79903640b4d18b2f16e04f9e0f61c. Drifblim decoded SHA256:
79b8d946cfacf8875b76c9d9fcf025c57138b12b69c2a75650a4a41954eda37a.
Repeated bootstrap returned 0 using the existing source cache.

Output check using Python 3.10 returned 0: 540 HTML paths counted; home.html
checked for document boundaries; img.xml and log.xml parsed as RSS with items.
A malformed log.xml fixture was rejected with a nonzero status, then restored.
Missing output directory was rejected. CRLF and corrupt-ROM guards passed.
The full build used a path containing spaces successfully.
Upstream makefile/content were not edited and no push target was invoked.

## Decisions and review

Engineering notes live under .github/development because docs/ is indexed by the
upstream generator. This changes only documentation placement.
The CRLF probe uses GNU grep -U -P with a regex escape: literal CR command-line
arguments are stripped on MSYS, and its default grep text handling strips CRLF.
The regression script covers both CRLF rejection and LF acceptance.

Independent static review found no Critical/Important issues. Deferred minor:
the verifier's success line says "Verified N HTML pages" although N is a count;
only home.html and the two feeds are substantively checked.

## Pending

The Linux workflow is configured but has not run on GitHub: the branch is local.
Push/create a PR to run hosted Linux verification. Visual browser inspection of
the generated site and completion of HAR-109 remain pending. No deployment or
remote branch changes have been made.

Last successful command: generated-output and malformed-RSS verification.
Next step: push this feature branch to the fork and create a PR to main; inspect CI.
