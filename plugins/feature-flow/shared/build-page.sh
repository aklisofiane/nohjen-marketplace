#!/usr/bin/env bash
# Builds a feature-flow answerable page in one step: the content Claude writes, plus the shared runtime,
# written to a temp file and moved into place, so a viewer never opens it half-built.
#
#   build-page.sh OUT [--md FILE] [--proof DIR] < content     new page (brainstorm, bug, report, or spec with --md)
#   build-page.sh OUT --rebuild --md FILE                     spec page: keep OUT's own layer, re-render FILE
#
#   --md FILE     spec page: FILE becomes the markdown the page renders, after the layer
#   --proof DIR   report page: each src="proof:<name>" becomes DIR/<name> inlined as a data: URI
#   --rebuild     take the layer from OUT itself (everything above its markdown block) instead of stdin
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
runtime="$here/page-runtime.html"
marker='<script type="text/markdown" id="spec">'
die() { echo "build-page: $*" >&2; exit 1; }

[ $# -ge 1 ] || die "usage: build-page.sh OUT [--md FILE] [--proof DIR] [--rebuild]"
out="$1"; shift
md="" proof="" rebuild=""
while [ $# -gt 0 ]; do
  case "$1" in
    --md) md="${2:?--md needs a file}"; shift 2 ;;
    --proof) proof="${2:?--proof needs a folder}"; shift 2 ;;
    --rebuild) rebuild=1; shift ;;
    *) die "unknown argument: $1" ;;
  esac
done
[ -f "$runtime" ] || die "runtime not found at $runtime"
[ -z "$md" ] || [ -f "$md" ] || die "no markdown file at $md"
[ -z "$rebuild" ] || [ -n "$md" ] || die "--rebuild needs --md"

mkdir -p "$(dirname "$out")"
tmp="$(mktemp "$out.XXXXXX")"
trap 'rm -f "$tmp" "$tmp.layer"' EXIT

# 1. The layer or content: from the page itself (--rebuild) or from stdin
if [ -n "$rebuild" ]; then
  [ -f "$out" ] || die "nothing to rebuild at $out"
  grep -qF "$marker" "$out" || die "$out has no markdown block to rebuild around"
  awk -v m="$marker" 'index($0, m) { exit } { print }' "$out" > "$tmp"
else
  [ ! -t 0 ] || die "pipe the page content on stdin (a heredoc)"
  cat > "$tmp"
  [ -s "$tmp" ] || die "the page content on stdin is empty"
fi

# 2. Report screenshots, inlined so the page stays one file
if [ -n "$proof" ]; then
  P="$proof" perl -0777 -i -MMIME::Base64 -pe 's{src="proof:([^"]+)"}{open(my $f, "<:raw", "$ENV{P}/$1") or die "build-page: screenshot $1: $!\n"; local $/; "src=\"data:image/" . ($1 =~ /\.jpe?g$/i ? "jpeg" : "png") . ";base64," . encode_base64(<$f>, "") . "\""}ge' "$tmp"
fi

# 3. A spec page's markdown; </script and <!-- are escaped so they can't end the block early (the page shows them back)
if [ -n "$md" ]; then
  grep -vF "$marker" "$tmp" > "$tmp.layer" || true
  { cat "$tmp.layer"; echo "$marker"; sed -e 's#</\([Ss][Cc][Rr][Ii][Pp][Tt]\)#<\\/\1#g' -e 's#<!--#<\\!--#g' "$md"; } > "$tmp"
  rm -f "$tmp.layer"
fi

# 4. The runtime, never retyped or linked: the desktop side panel loads the page as a standalone copy
cat "$runtime" >> "$tmp"
chmod 644 "$tmp"
mv "$tmp" "$out"
trap - EXIT
echo "$out"
