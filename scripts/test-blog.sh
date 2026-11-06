#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
EMU=${EMU:-$ROOT/.toolchain/bin/uxncli}
[ -x "$EMU" ] || EMU="$EMU.exe"
DRIFBLIM=${DRIFBLIM:-$ROOT/.toolchain/roms/drifblim.rom}
. "$ROOT/scripts/uxn-test-lib.sh"
expect_blog_failure() {
    if uxn_test log.rom > error.txt 2>&1; then
        echo 'FAIL invalid blog input returned success' >&2; exit 1
    else
        blog_status=$?
        [ "$blog_status" -eq 1 ] || { cat error.txt >&2; echo "FAIL expected ROM status1, got $blog_status" >&2; exit 1; }
    fi
}
T=$(mktemp -d /tmp/oscean-blog-test.XXXXXX)
T=$(CDPATH= cd -- "$T" && pwd -P)
case "$T" in /tmp/oscean-blog-test.*) ;; *) echo "Unsafe fixture path" >&2; exit 1;; esac
trap 'rm -rf "$T"' EXIT
mkdir -p "$T/src/blog" "$T/src/htm" "$T/links"
cp "$ROOT/src/log.tal" "$T/log.tal"
cd "$T"
uxn_test "$DRIFBLIM" log.tal log.rom
printf 'https://example.org/wiki/\n' > src/site-url.txt
printf '%s\n' 2024-02-29-first > src/blog/index.txt
printf 'A & <title>\n<p>Body & text ]]>.</p>\n' > src/blog/2024-02-29-first.htm
uxn_test log.rom
[ -f src/htm/blog.htm ] || { echo 'FAIL: missing native blog output'; exit 1; }
grep -q '2024-02-29-first' src/htm/blog.htm
grep -q 'A &amp; &lt;title&gt;' links/log.xml
grep -q '<link>https://example.org/wiki/site/blog.html</link>' links/log.xml || { echo 'FAIL channel URL whitespace'; exit 1; }
grep -q '<link>https://example.org/wiki/site/blog.html#2024-02-29-first</link>' links/log.xml
grep -q '<description>2024-02-29 A &amp; &lt;title&gt;</description>' links/log.xml
if grep -q 'Body' links/log.xml; then echo 'FAIL feed contains body'; exit 1; fi
grep -q '2024-02-29 A &amp; &lt;title&gt;' src/htm/blog.htm
cp links/log.xml before.xml
uxn_test log.rom
[ "$(cksum < before.xml)" = "$(cksum < links/log.xml)" ]
for id in 1900-02-29-bad 2023-02-29-bad 0000-01-01-bad 2024-13-01-bad 2024-04-31-bad 2024-01-00-bad 2024-01-01-../bad; do
 printf '%s\n' "$id" > src/blog/index.txt
expect_blog_failure
 grep -q 'blog:' error.txt
done
printf '%s\n' 2024-02-29-missing > src/blog/index.txt
expect_blog_failure
printf '%s\n' 2024-02-29-first 2024-02-29-first > src/blog/index.txt
expect_blog_failure
printf '%s\n' 2000-02-29-old 2024-02-29-first > src/blog/index.txt
printf 'Old\n<p>Old</p>\n' > src/blog/2000-02-29-old.htm
expect_blog_failure
printf '%s\n' 2024-02-29-first 2024-02-29-second 2000-02-29-old 0001-01-01-earliest > src/blog/index.txt
printf 'Second\n<p>Second</p>\n' > src/blog/2024-02-29-second.htm
printf 'Earliest\n<p>Earliest</p>\n' > src/blog/0001-01-01-earliest.htm
uxn_test log.rom
grep -q 'Thu, 29 Feb 2024' links/log.xml
grep -q 'Tue, 29 Feb 2000' links/log.xml
grep -q 'Mon, 1 Jan 0001' links/log.xml
sed -n 's/.*<article id="\([^"]*\)".*/\1/p' src/htm/blog.htm > actual.txt
[ "$(cat src/blog/index.txt)" = "$(cat actual.txt)" ]
for base in 'relative/' 'https://example.org' 'ftp://example.org/' 'https://' 'https://example.org/?q=/' 'https://bad quote/'; do
 printf '%s\n' "$base" > src/site-url.txt
expect_blog_failure
done
rm src/site-url.txt
expect_blog_failure
printf 'https://example.org/wiki/\n' > src/site-url.txt
: > src/blog/index.txt
uxn_test log.rom
grep -q "No posts yet" src/htm/blog.htm
grep -q "<channel>" links/log.xml
if grep -q "<item>" links/log.xml; then echo "FAIL empty feed has items"; exit 1; fi
rm src/blog/index.txt
expect_blog_failure
echo 'Native blog regression tests passed'
