#!/usr/bin/env bash

set -euo pipefail

DIAGNOSTIC_COUNT=0
WARNING_COUNT=0

# GitHub Actions log formatting.
begin_group() {
	printf '::group::%s\n' "$1"
}

end_group() {
	printf '::endgroup::\n'
}

warn() {
	WARNING_COUNT=$((WARNING_COUNT + 1))
	printf '::warning::%s\n' "$1"
}

# Each command is independent so a broken tool does not hide later diagnostics.
run_diagnostic() {
	local title="$1"
	shift
	DIAGNOSTIC_COUNT=$((DIAGNOSTIC_COUNT + 1))
	begin_group "$title"
	printf '::debug::Running diagnostic command: %s\n' "$1"
	if ! command -v "$1" >/dev/null 2>&1; then
		warn "$1 is not available, skipping"
	elif "$@"; then
		:
	else
		warn "$1 failed (exit $?), continuing diagnostics"
	fi
	end_group
}

collect_system() {
	run_diagnostic 'Date (UTC)' date -u
	run_diagnostic 'System information' uname -a
}

collect_xcode_destinations() {
	if [[ -z "${INPUT_SCHEME:-}" ]]; then
		printf '::debug::Skipping destinations: no scheme supplied\n'
		return
	fi

	# Workspace takes precedence when both workspace and project are supplied.
	if [[ -n "${INPUT_WORKSPACE:-}" ]]; then
		run_diagnostic 'Available destinations' xcodebuild \
			-workspace "$INPUT_WORKSPACE" -scheme "$INPUT_SCHEME" -showdestinations
	elif [[ -n "${INPUT_PROJECT:-}" ]]; then
		run_diagnostic 'Available destinations' xcodebuild \
			-project "$INPUT_PROJECT" -scheme "$INPUT_SCHEME" -showdestinations
	else
		printf '::debug::Skipping destinations: no workspace or project supplied\n'
	fi
}

collect_macos() {
	local app found_xcode=false

	run_diagnostic 'macOS version' sw_vers

	begin_group 'Developer directory'
	printf 'DEVELOPER_DIR=%s\n' "${DEVELOPER_DIR:-<not set>}"
	end_group
	run_diagnostic 'Selected developer directory' xcode-select -p

	begin_group 'Installed Xcode applications'
	for app in /Applications/Xcode*; do
		if [[ -d "$app" ]]; then
			printf '%s\n' "${app##*/}"
			found_xcode=true
		fi
	done
	if [[ "$found_xcode" == false ]]; then
		warn 'No Xcode apps found in /Applications'
	fi
	end_group

	run_diagnostic 'Active Xcode' xcodebuild -version
	run_diagnostic 'Installed SDKs' xcodebuild -showsdks
	run_diagnostic 'SDK details' xcodebuild -version -sdk
	run_diagnostic 'Available simulator runtimes' xcrun simctl list runtimes
	run_diagnostic 'Available simulator device types' xcrun simctl list devicetypes
	run_diagnostic 'Available simulator devices' xcrun simctl list devices available
	collect_xcode_destinations
	run_diagnostic 'Hardware summary' sysctl hw.model hw.machine hw.ncpu hw.memsize
}

collect_linux() {
	if [[ -r /etc/os-release ]]; then
		run_diagnostic 'Linux distribution' cat /etc/os-release
	fi
	run_diagnostic 'CPU information' lscpu
	run_diagnostic 'Memory information' free -h
}

write_summary() {
	[[ -n "${GITHUB_STEP_SUMMARY:-}" ]] || return 0

	if {
		printf '### diagnostics\n\n'
		printf '| Platform | Commands checked | Warnings |\n'
		printf '| --- | ---: | ---: |\n'
		printf '| %s | %s | %s |\n\n' "$1" "$DIAGNOSTIC_COUNT" "$WARNING_COUNT"
		printf 'See the grouped step logs for full diagnostic output.\n'
	} >>"$GITHUB_STEP_SUMMARY"; then
		:
	else
		warn 'Unable to write the job summary, see the step logs for diagnostics'
	fi
}

main() {
	local platform
	platform="$(uname -s)" || platform=unknown

	printf '::notice::Starting diagnostics\n'
	collect_system
	case "$platform" in
	Darwin) collect_macos ;;
	Linux) collect_linux ;;
	*) warn 'Platform is not supported, collecting general diagnostics only' ;;
	esac
	run_diagnostic 'Disk space' df -h
	write_summary "$platform"
	printf '::notice::Completed diagnostics (%s commands checked, %s warnings)\n' \
		"$DIAGNOSTIC_COUNT" "$WARNING_COUNT"
}

main "$@"
