#!/usr/bin/env bash
# Package the browser build as malu123-web_<version>_all.deb (Malu123 addition, not upstream).
#
#   packaging/web/deb.sh [--skip-build]     needs nfpm; --skip-build reuses dist/web
set -euo pipefail
# shellcheck source=../env.sh
. "$(dirname "${BASH_SOURCE[0]}")/../env.sh"
SITE="$ROOT/dist/web"
if [[ "${1:-}" != "--skip-build" ]]; then
  "$ROOT/packaging/web/package.sh"
fi
[[ -f "$SITE/index.html" ]] || { echo "error: $SITE/index.html missing; run without --skip-build" >&2; exit 1; }
command -v nfpm >/dev/null || { echo "error: nfpm not found (https://nfpm.goreleaser.com)" >&2; exit 1; }
WORK="${CARGO_TARGET_DIR:-$ROOT/target}/web-package"
rm -rf "$WORK"; mkdir -p "$WORK/site"
cp -R "$SITE"/. "$WORK/site/"
rm -f "$WORK/site/_headers" "$WORK/site/.htaccess" "$WORK/site/.trunk-lock"
export STAGE="$WORK" NFPM_ARCH=all
sed "s|\${STAGE}|$STAGE|g" "$ROOT/packaging/web/nfpm.yaml" >"$WORK/nfpm.yaml"
(cd "$ROOT" && nfpm package -f "$WORK/nfpm.yaml" -p deb -t "$DIST/")
ls -la "$DIST"/malu123-web_*.deb
