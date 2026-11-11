#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BASH_BIN="$BASH"
TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TEMP_DIR"' EXIT
mkdir -p "$TEMP_DIR/bin"

# Replace host tools so tests do not invoke Xcode or depend on the host OS.
for tool in uname date sw_vers xcode-select xcodebuild xcrun sysctl df lscpu free cat; do
	cat >"$TEMP_DIR/bin/$tool" <<'STUB'
#!/bin/bash
name="${0##*/}"
if [[ "$name" == uname && "${1:-}" == -s ]]; then
  printf '%s\n' "$TEST_OS"
  exit 0
fi
printf '%s' "$name"
for arg in "$@"; do
  printf ' <%s>' "$arg"
done
printf '\n'
if [[ "$name" == "${FAIL_TOOL:-}" ]]; then
  exit 42
fi
STUB
	chmod +x "$TEMP_DIR/bin/$tool"
done

run_diagnostics() {
	: >"$TEMP_DIR/summary"
	env PATH="$TEMP_DIR/bin" TEST_OS="$TEST_OS" FAIL_TOOL="${FAIL_TOOL:-}" \
		DEVELOPER_DIR='/Applications/Xcode.app/Contents/Developer' \
		INPUT_WORKSPACE="${WORKSPACE:-}" INPUT_PROJECT="${PROJECT:-}" INPUT_SCHEME="${SCHEME:-}" \
		GITHUB_STEP_SUMMARY="${SUMMARY_PATH-$TEMP_DIR/summary}" \
		"$BASH_BIN" "$ROOT/scripts/main.sh" >"$TEMP_DIR/output" 2>&1
}

contains() {
	if ! grep -F -- "$1" "$TEMP_DIR/output" >/dev/null; then
		printf 'FAIL: expected output to contain: %s\n' "$1" >&2
		cat "$TEMP_DIR/output" >&2
		exit 1
	fi
}

excludes() {
	if grep -F -- "$1" "$TEMP_DIR/output" >/dev/null; then
		printf 'FAIL: unexpected output: %s\n' "$1" >&2
		exit 1
	fi
}

TEST_OS=Linux
if ! run_diagnostics; then
	printf 'FAIL: Linux diagnostics must succeed\n' >&2
	cat "$TEMP_DIR/output" >&2
	exit 1
fi
contains 'uname <-a>'
contains 'lscpu'
contains 'free <-h>'
contains 'df <-h>'
excludes 'xcodebuild'
excludes 'xcrun'
excludes 'sw_vers'
printf 'PASS: Linux diagnostics do not invoke Apple tools\n'

TEST_OS=Darwin
run_diagnostics
contains 'sw_vers'
contains 'xcode-select <-p>'
contains 'xcodebuild <-version>'
contains 'xcodebuild <-showsdks>'
contains 'xcodebuild <-version> <-sdk>'
contains 'xcrun <simctl> <list> <runtimes>'
contains 'xcrun <simctl> <list> <devicetypes>'
contains 'xcrun <simctl> <list> <devices> <available>'
contains 'sysctl <hw.model> <hw.machine> <hw.ncpu> <hw.memsize>'
excludes 'system_profiler'
excludes 'lscpu'
excludes '-showdestinations'
printf 'PASS: macOS diagnostics include Xcode and simulators without assuming a project\n'

SCHEME=App
run_diagnostics
excludes '-showdestinations'
printf 'PASS: destination check requires a workspace or project\n'

WORKSPACE='App With Spaces.xcworkspace'
SCHEME="App \$(touch should-not-exist); *"
run_diagnostics
contains "xcodebuild <-workspace> <App With Spaces.xcworkspace> <-scheme> <App \$(touch should-not-exist); *> <-showdestinations>"
printf 'PASS: workspace and scheme are passed as literal arguments\n'

WORKSPACE=''
PROJECT='App With Spaces.xcodeproj'
run_diagnostics
contains "xcodebuild <-project> <App With Spaces.xcodeproj> <-scheme> <App \$(touch should-not-exist); *> <-showdestinations>"
printf 'PASS: project destination check is configurable\n'

WORKSPACE='Preferred.xcworkspace'
run_diagnostics
contains 'xcodebuild <-workspace> <Preferred.xcworkspace> <-scheme>'
excludes '<-project>'
printf 'PASS: workspace takes precedence over project\n'

SCHEME=''
run_diagnostics
excludes '-showdestinations'
printf 'PASS: destination check requires a scheme\n'

SCHEME=App
FAIL_TOOL=xcodebuild
run_diagnostics
contains '::warning::'
contains 'xcrun <simctl> <list> <devices> <available>'
contains 'df <-h>'
contains 'Completed diagnostics'
printf 'PASS: failed diagnostic commands do not prevent later diagnostics\n'

FAIL_TOOL=xcode-select
run_diagnostics
contains 'xcodebuild <-version>'
contains 'Completed diagnostics'
printf 'PASS: broken developer directory does not abort diagnostics\n'

FAIL_TOOL=''
rm "$TEMP_DIR/bin/xcodebuild" "$TEMP_DIR/bin/xcrun" "$TEMP_DIR/bin/sysctl"
run_diagnostics
contains '::warning::'
contains 'df <-h>'
contains 'Completed diagnostics'
printf 'PASS: missing optional tools do not fail diagnostics\n'

TEST_OS=Linux
FAIL_TOOL='df'
run_diagnostics
contains 'Completed diagnostics'
printf 'PASS: failed disk diagnostics still complete successfully\n'

groups="$(grep -c '^::group::' "$TEMP_DIR/output")"
ends="$(grep -c '^::endgroup::$' "$TEMP_DIR/output")"
[[ "$groups" -gt 0 && "$groups" -eq "$ends" ]]
printf 'PASS: diagnostic log groups are balanced\n'

contains '::debug::'
grep -F 'diagnostics' "$TEMP_DIR/summary" >/dev/null
grep -F 'Linux' "$TEMP_DIR/summary" >/dev/null
grep -E '^\| Linux \| [0-9]+ \| 1 \|$' "$TEMP_DIR/summary" >/dev/null
printf 'PASS: debug logs and a job summary supplement grouped diagnostics\n'

FAIL_TOOL=''
run_diagnostics
excludes 'xcodebuild'
excludes 'xcrun'
printf 'PASS: Xcode inputs are ignored on Linux\n'

SUMMARY_PATH=''
run_diagnostics
[[ ! -s "$TEMP_DIR/summary" ]]
contains 'Completed diagnostics'
printf 'PASS: the script works without a job summary outside Actions\n'

SUMMARY_PATH="$TEMP_DIR"
run_diagnostics
contains '::warning::Unable to write the job summary'
contains 'Completed diagnostics'
printf 'PASS: an unwritable job summary does not fail diagnostics\n'
