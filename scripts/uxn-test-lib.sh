# Source from ROM tests after setting EMU. GNU timeout is in existing coreutils.
timeout --version 2>/dev/null | grep -q 'GNU coreutils' || { echo 'GNU timeout (coreutils) is required' >&2; exit 1; }
uxn_test() {
    [ "$#" -gt 0 ] && [ -f "$1" ] || { echo 'ROM file is missing' >&2; exit 2; }
    # Whole seconds only; zero must never disable the deadline.
    uxn_test_seconds=${UXN_TEST_TIMEOUT:-5}
    case "$uxn_test_seconds" in
        [1-9]|[1-5][0-9]|60) ;;
        *) echo 'Invalid UXN_TEST_TIMEOUT: use whole seconds from 1 through 60' >&2; exit 2 ;;
    esac
    if timeout --kill-after=1s "$uxn_test_seconds" "$EMU" "$@" </dev/null; then
        return 0
    else
        uxn_test_status=$?
    fi
    case "$uxn_test_status" in
        124|137)
            echo 'ROM test timed out; this is not an expected ROM rejection' >&2
            exit "$uxn_test_status"
            ;;
    esac
    return "$uxn_test_status"
}
