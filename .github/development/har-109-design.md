# HAR-109 approved design

Make the unchanged upstream build reproducible using the verified dedicated uxncli commit 8d8bb97c33e79903640b4d18b2f16e04f9e0f61c and the bundled Drifblim ROM (SHA256 79b8d946cfacf8875b76c9d9fcf025c57138b12b69c2a75650a4a41954eda37a).

Use shared Bash bootstrap/build scripts on Windows MSYS2 MSYS and Linux. Enforce LF text inputs. Record prerequisite versions and commands. Add Linux CI that builds and checks HTML/RSS outputs. Keep upstream makefile and content unchanged. Do not deploy or push.

Approaches: reuse the verified Bash/GCC path (chosen); port Unix file APIs to MSVC (unnecessary maintenance); require WSL (conflicts with owner preference). Owner approved the design on 2026-11-05.

Implementation choices: cache tools in ignored .toolchain/; always rebuild the small CLI from its pinned source; validate the bundled ROM checksum; fail before site generation on CRLF inputs; document that make run rewrites generated outputs. Place engineering notes under .github/development to avoid the upstream docs directory index.