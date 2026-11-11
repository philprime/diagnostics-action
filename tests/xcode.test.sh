#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BASH_BIN="$BASH"
TEMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/diagnostics-xcode.XXXXXX")"

cleanup() {
	local status=$?
	if [[ "$status" == 0 ]]; then
		rm -rf "$TEMP_DIR"
	else
		printf 'Xcode integration logs: %s\n' "$TEMP_DIR" >&2
	fi
}
trap cleanup EXIT

mkdir -p "$TEMP_DIR/bin"
cp "$ROOT/tests/xcodebuild-probe.sh" "$TEMP_DIR/bin/xcodebuild"
chmod +x "$TEMP_DIR/bin/xcodebuild"
export REAL_XCODEBUILD
REAL_XCODEBUILD="$(xcrun --find xcodebuild)"
export XCODE_DESTINATION_RESULTS="$TEMP_DIR/results"
export PATH="$TEMP_DIR/bin:$PATH"

INPUT_PROJECT="$ROOT/tests/fixtures/Diagnostics.xcodeproj" INPUT_WORKSPACE='' INPUT_SCHEME=Diagnostics \
	"$BASH_BIN" "$ROOT/scripts/main.sh" >"$TEMP_DIR/project.log" 2>&1
INPUT_WORKSPACE="$ROOT/tests/fixtures/Diagnostics.xcworkspace" INPUT_PROJECT='' INPUT_SCHEME=Diagnostics \
	"$BASH_BIN" "$ROOT/scripts/main.sh" >"$TEMP_DIR/workspace.log" 2>&1

[[ "$(cat "$XCODE_DESTINATION_RESULTS")" == $'0\n0' ]]
printf 'PASS: real Xcode project and workspace destination checks succeeded\n'
