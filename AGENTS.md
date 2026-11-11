# Agent Instructions

## Runtime and verification

- Keep the action container-free and dependency-free. Use Bash compatible with macOS's system Bash 3.2 and Linux.
- Use `just` for development tasks. `just setup` installs macOS tooling and pre-commit hooks.
- `just test` runs shell behavior tests. `just test-bash /bin/bash` verifies the macOS system interpreter. `just test-xcode` checks real Xcode destinations. Always run tests through `just`.
- Source the CI Node version from `.nvmrc` using `node-version-file`. Node is development tooling only. Do not add it to the Brewfile.
- `just lint` runs ShellCheck and actionlint. `just format-check` verifies dprint and Justfile formatting.
- `just format` formats JSON, Markdown, YAML, shell scripts, and the Justfile. Dprint owns shell formatting too.
- `just analyze` runs all static checks. `just check` also runs tests. `just hooks` runs all pre-commit checks. There is no build step.
- Diagnostics are best-effort. Missing or failing system tools must not prevent remaining checks or fail the action.
- Do not dump the environment, credentials, or arbitrary user files into diagnostic logs.

## Workflows and inputs

- Test the composite action on both macOS and Linux. Use the local action for workflow failure diagnostics too.
- Pin external workflow actions to full commit SHAs and disable persisted checkout credentials. Keep normal workflow permissions read-only.
- Publishing must test the exact release commit before creating tags. Never replace full-version release tags.
- Keep GitHub log grouping, annotations, debug messages, and the job summary in `scripts/main.sh`.
- Pass action inputs via step environment variables and use quoted Bash arguments. Never interpolate inputs into script bodies or use eval.
- Prefer `actions/github-script` for GitHub API calls and workflow logic. Reserve shell for simple commands.
- Use `jq` for JSON and `yq` for YAML processing in shell.

## Compaction

After every compaction operation, read this file again before continuing.
