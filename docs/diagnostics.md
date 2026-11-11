# Diagnostic behavior

## Collected information

| Platform        | Diagnostics                                                                                                                                                                                           |
| --------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| macOS and Linux | UTC date, system information, disk usage.                                                                                                                                                             |
| macOS           | OS version, developer directory, installed Xcode applications, active Xcode, SDKs, simulator runtimes, device types, available devices, hardware model, architecture, CPU count, and memory capacity. |
| Linux           | OS distribution, CPU information, memory usage.                                                                                                                                                       |

On macOS, supplying a scheme and a workspace or project also runs `xcodebuild -showdestinations`. The workspace takes precedence if both paths are supplied. Without a scheme and a workspace or project, that check is skipped.

The caller chooses when the action runs using a step condition such as `if: failure()`. The action does not inspect previous step outcomes.

## Logs and summary

Output uses collapsible log groups, start/completion notices, and warning annotations. Debug messages are visible when GitHub Actions step debugging is enabled. A job summary reports the platform, number of commands checked, and warning count. Full command output stays in the step logs.

Missing tools, failed commands, and timeouts produce warnings without failing the action. No environment dump or artifact upload is performed. Logs can still contain hostnames, paths, project metadata, and tool output. See [Security](../SECURITY.md) before using sensitive self-hosted runners.

## Timeouts

The [`timeout` and `command-timeout` inputs](../README.md#inputs) accept integers from 1 to 3600 seconds. Invalid values produce warnings and use the defaults.

Each command is limited by its per-command timeout and the remaining overall budget. A timed-out command and its process group receive a termination signal, followed by a forced stop after one second. Later commands continue while budget remains. When the overall budget is exhausted, later commands are skipped.

Allow up to one additional second beyond the overall budget for process termination. These limits apply to diagnostic commands, not the rest of the caller's job.

## Runner requirements and permissions

- GitHub-hosted macOS and Linux runners are supported. Windows runners are not supported.
- Self-hosted runners need Bash 3.2 or newer and standard system utilities, including `sleep` with fractional-second support.
- Xcode-specific diagnostics require Xcode and its command-line tools. Missing tools produce warnings rather than failing the action.
- Docker, Node.js, GNU `timeout`, and package installation are not required.

The action needs no GitHub token or GitHub API permissions. Choose workflow permissions based on the other steps in your job. For example, checking out a private repository requires `contents: read`.

See the [README](../README.md) for usage examples and inputs.
