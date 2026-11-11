#!/usr/bin/env bash

# Observe the real command at the system-tool boundary during CI integration tests.
set -uo pipefail

if [[ " $* " == *" -showdestinations "* ]]; then
	"$REAL_XCODEBUILD" "$@"
	status=$?
	printf '%s\n' "$status" >>"$XCODE_DESTINATION_RESULTS"
	exit "$status"
fi

exec "$REAL_XCODEBUILD" "$@"
