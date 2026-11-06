#!/usr/bin/env bash
# Integration checks for guards, without network access or site generation.
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
scratch=$(mktemp -d /tmp/oscean-build-test.XXXXXX)
# mktemp creates this exact absolute prefix; cleanup stays inside that directory.
trap 'case "$scratch" in /tmp/oscean-build-test.*) rm -rf -- "$scratch" ;; esac' EXIT
mkdir -p "$scratch/scripts" "$scratch/src/logs" "$scratch/etc"
cp "$root/scripts/build.sh" "$root/scripts/bootstrap.sh" "$scratch/scripts/"
printf 'home\r\n' > "$scratch/src/lexicon"
printf '00\n' > "$scratch/etc/drifblim.rom.txt"
if bash "$scratch/scripts/build.sh" > "$scratch/result.log" 2>&1; then
    echo 'Expected CRLF rejection' >&2; exit 1
fi
grep -q 'CRLF build inputs detected' "$scratch/result.log"
[[ ! -e "$scratch/.toolchain" ]]
printf 'home\n' > "$scratch/src/lexicon"
if bash "$scratch/scripts/build.sh" > "$scratch/result.log" 2>&1; then
    echo 'Expected corrupt ROM rejection' >&2; exit 1
fi
if grep -q 'CRLF build inputs detected' "$scratch/result.log"; then
    echo 'LF input was incorrectly rejected' >&2; exit 1
fi
grep -q 'FAILED' "$scratch/result.log"
[[ ! -e "$scratch/.toolchain/roms/drifblim.rom" ]]
[[ ! -e "$scratch/.toolchain/uxncli" ]]
echo 'Passed: CRLF rejected before writes, LF accepted, corrupt ROM rejected before fetch'
