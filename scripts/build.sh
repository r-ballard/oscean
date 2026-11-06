#!/usr/bin/env bash
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
cd "$root"
command -v make >/dev/null || { echo 'Missing prerequisite: make (see BUILDING.md)' >&2; exit 1; }
# File devices read binary bytes: CRLF changes lexicon names and breaks paths.
crlf=$(grep -rIl $'\r' src etc --include='*.tal' --include='*.tal.txt' --include='*.htm' --include='lexicon' --include='*.tsv' || [[ $? == 1 ]])
if [[ -n "$crlf" ]]; then
    printf 'CRLF build inputs detected. Use a fresh LF checkout; see BUILDING.md.\n' >&2
    printf '%s\n' "$crlf" | head -n 10 >&2
    exit 1
fi
bash "$root/scripts/bootstrap.sh"
cli="$root/.toolchain/bin/uxncli"
[[ ! -f "$cli.exe" ]] || cli="$cli.exe"
rom="$root/.toolchain/roms/drifblim.rom"
mkdir -p bin
# Embedded quoting survives make expansion in the unchanged upstream recipes.
make run EMU="\"$cli\"" ASM="\"$cli\" \"$rom\"" DIR="$root/.toolchain/roms"
