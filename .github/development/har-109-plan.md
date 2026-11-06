# HAR-109 implementation plan

Goal: repeatable native Windows/MSYS2 and Linux setup for the upstream Oscean build.
Architecture: Bash scripts pin/fetch/compile CLI and decode/check bundled assembler, then invoke unchanged make run. CI calls the same entry point.
Tech stack: Bash, Git, GCC, Make, awk, sha256sum; Python 3 for CI output verification.
Spec: .github/development/har-109-design.md

Constraints: no WSL; exact CLI commit/ROM checksum from spec; upstream makefile unchanged; no publishing.
Review focus: CRLF checkout rejected before writes; dependency fetch failure stops build; corrupt ROM rejected; paths with spaces work; generated outputs validated.

## Task 1: pinned bootstrap and build
Files: scripts/bootstrap.sh, scripts/build.sh, .gitattributes, .gitignore, BUILDING.md, README.md.
Interface: bootstrap creates .toolchain/bin/uxncli and .toolchain/roms/drifblim.rom; build invokes bootstrap then make run with absolute EMU/DIR overrides.
- [ ] Verify baseline invocation fails because entry point does not exist.
- [ ] Implement bootstrap/build and documentation.
- [ ] Validate scripts, CRLF rejection, ROM integrity rejection, fresh checkout full build, second bootstrap.

## Task 2: Linux CI and verification
Files: .github/workflows/build.yml, scripts/check-output.py.
Interface: build generates site/*.html and links/{img,log}.xml; verifier validates home HTML and XML roots/items.
- [ ] Run verifier before outputs exist and confirm failure.
- [ ] Add verifier and CI workflow.
- [ ] Run verifier against fresh build and malformed feed fixture.
- [ ] Review final diff and record results.

Execution: inline by the current agent, as requested by owner to proceed. Review by a separate agent after implementation. No push or merge.