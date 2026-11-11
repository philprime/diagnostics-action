# Contributing

## Setup

On macOS, install [just](https://just.systems), then install the development tools and Git hooks:

```sh
brew install just
just setup
```

On Linux, install the tools listed in the [Brewfile](Brewfile) using your preferred package manager, then run `just install-pre-commit`.

The action and its behavior tests use Bash. Local checks do not require Node.js or a Node version manager. CI toolchain configuration lives in the [CI workflow](.github/workflows/ci.yml) and [.nvmrc](.nvmrc).

## Checks

Use `just` for development commands. Run `just` without arguments to list available recipes.

| Command                    | Purpose                                                       |
| -------------------------- | ------------------------------------------------------------- |
| `just format`              | Format supported files and the Justfile.                      |
| `just check`               | Run static checks and shell behavior tests.                   |
| `just test`                | Run shell behavior tests.                                     |
| `just test-bash /bin/bash` | Verify compatibility with macOS's system Bash.                |
| `just test-xcode`          | Check real Xcode project and workspace destinations on macOS. |
| `just hooks`               | Run all pre-commit checks against tracked files.              |

For documentation-only changes, use `just format-check` to verify formatting. Pre-commit hooks format changed files and validate applicable file types. Xcode integration checks require Xcode and do not build the fixture.

## Making changes

- Keep the runtime compatible with Bash 3.2 on macOS and Bash on Linux. Do not introduce container or runtime package dependencies.
- Keep diagnostics best-effort. Missing or failed commands must not prevent later checks. Use GitHub's native `timeout-minutes` setting for execution limits.
- Add behavior tests for runtime changes. Update [action metadata](action.yml) and the [README](README.md) when inputs change.
- Do not log credentials, dump the environment, or collect unique hardware identifiers.
- Explain the problem, rationale, and checks performed in your pull request. Report vulnerabilities through the [security reporting process](SECURITY.md), not public issues.

The runtime entry point is [`scripts/main.sh`](scripts/main.sh). CI exercises both platforms and real Xcode destination inputs. Diagnostics also run after genuine CI failures.

Maintainers can find publishing instructions and repository protection requirements in [Releases](docs/releases.md).
