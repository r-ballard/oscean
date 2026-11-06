#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
EMU=${EMU:-$ROOT/.toolchain/bin/uxncli}
[ -x "$EMU" ] || EMU="$EMU.exe"
DRIFBLIM=${DRIFBLIM:-$ROOT/.toolchain/roms/drifblim.rom}
. "$ROOT/scripts/uxn-test-lib.sh"
T=$(mktemp -d /tmp/oscean-uxn-test.XXXXXX)
T=$(CDPATH= cd -- "$T" && pwd -P)
case "$T" in /tmp/oscean-uxn-test.*) ;; *) echo 'Unsafe fixture path' >&2; exit 1;; esac
trap 'rm -rf "$T"' EXIT
cp "$ROOT"/tests/uxn/*.tal "$T/"
cd "$T"
for source in *.tal; do
    uxn_test "$DRIFBLIM" "$source" "${source%.tal}.rom"
done
uxn_test brk.rom
uxn_test stack-short.rom
if uxn_test exit-one.rom; then
    echo 'FAIL explicit error returned success' >&2; exit 1
else
    result=$?
    [ "$result" -eq 1 ] || { echo "FAIL expected status1, got $result" >&2; exit 1; }
fi
uxn_test console-brk.rom > console.txt
[ "$(cat console.txt)" = X ] || { echo 'FAIL BRK console callback' >&2; exit 1; }
for rom in loop.rom state-loop.rom; do
    if timeout --kill-after=1s 0.2s "$EMU" "$rom" </dev/null; then
        echo "FAIL $rom unexpectedly terminated" >&2; exit 1
    else
        result=$?
        [ "$result" -eq 124 ] || { echo "FAIL watchdog status $result" >&2; exit 1; }
    fi
done
# The runner must abort even when a caller expects a ROM failure.
if ( if UXN_TEST_TIMEOUT=1 uxn_test loop.rom; then exit 0; else exit 0; fi ) > watchdog.txt 2>&1; then
    echo 'FAIL timeout was swallowed as an expected rejection' >&2; exit 1
else
    result=$?
    [ "$result" -eq 124 ] || { cat watchdog.txt >&2; exit 1; }
fi
grep -q 'ROM test timed out' watchdog.txt
for bad_limit in 0 -1 invalid 999; do
    if timeout --kill-after=1s 2s env UXN_TEST_TIMEOUT="$bad_limit" sh -c '. "$1"; EMU="$2"; uxn_test "$3"' _ "$ROOT/scripts/uxn-test-lib.sh" "$EMU" "$T/loop.rom" > bad-limit.txt 2>&1; then
        echo 'FAIL invalid timeout accepted' >&2; exit 1
    else
        result=$?
        [ "$result" -eq 2 ] || { echo "FAIL invalid timeout status $result" >&2; exit 1; }
    fi
done
# The pinned host reports a missing ROM on stdout but returns zero.
# Keep the runner from mistaking that host diagnostic for a successful test.
timeout --kill-after=1s 2s "$EMU" absent.rom </dev/null > missing-host.txt
grep -q 'Could not load' missing-host.txt
if ( uxn_test absent.rom ) > missing-runner.txt 2>&1; then
    echo 'FAIL runner accepted missing ROM' >&2; exit 1
else
    result=$?
    [ "$result" -eq 2 ] || { echo "FAIL missing ROM status $result" >&2; exit 1; }
fi
echo 'Pinned Uxn semantic probes passed'
