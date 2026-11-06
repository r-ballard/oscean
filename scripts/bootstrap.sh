#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
tools="$root/.toolchain"
revision=8d8bb97c33e79903640b4d18b2f16e04f9e0f61c
rom_hash=79b8d946cfacf8875b76c9d9fcf025c57138b12b69c2a75650a4a41954eda37a
for command in git gcc awk sha256sum; do
    command -v "$command" >/dev/null || { echo "Missing prerequisite: $command (see BUILDING.md)" >&2; exit 1; }
done
mkdir -p "$tools/bin" "$tools/roms"
rom_tmp=$(mktemp "$tools/roms/drifblim.XXXXXX")
trap 'rm -f -- "$rom_tmp"' EXIT
# Decode the versioned hexadecimal ROM without requiring Python or xxd.
awk '
function nibble(c) { return index("0123456789abcdef", tolower(c)) - 1 }
{ gsub(/[[:space:]]/, ""); hex = hex $0 }
END {
    if (length(hex) == 0 || length(hex) % 2) exit 1
    for (i = 1; i <= length(hex); i += 2) {
        a = nibble(substr(hex, i, 1)); b = nibble(substr(hex, i + 1, 1))
        if (a < 0 || b < 0) exit 1
        printf "%c", a * 16 + b
    }
}' "$root/etc/drifblim.rom.txt" > "$rom_tmp"
printf '%s  %s\n' "$rom_hash" "$rom_tmp" | sha256sum -c -
mv -f -- "$rom_tmp" "$tools/roms/drifblim.rom"
source_dir="$tools/uxncli"
if [[ ! -d "$source_dir/.git" ]]; then
    git clone --no-checkout https://git.sr.ht/~rabbits/uxncli "$source_dir"
fi
# The exception is scoped to this cache and this invocation, never global.
source_git=(git -c "safe.directory=$source_dir" -C "$source_dir")
if ! "${source_git[@]}" cat-file -e "$revision^{commit}" 2>/dev/null; then
    "${source_git[@]}" fetch origin "$revision"
fi
"${source_git[@]}" checkout --detach "$revision"
[[ $("${source_git[@]}" rev-parse HEAD) == "$revision" ]]
# Refuse tracked edits in the cached tool source.
"${source_git[@]}" diff --exit-code HEAD -- src/uxncli.c
suffix=
case $(uname -s) in MSYS*|MINGW*|CYGWIN*) suffix=.exe ;; esac
gcc -DNDEBUG -O3 -g0 -s "$source_dir/src/uxncli.c" -o "$tools/bin/uxncli$suffix"
"$tools/bin/uxncli$suffix" -v
printf 'Pinned CLI: %s\n' "$revision"
gcc --version | head -n 1
