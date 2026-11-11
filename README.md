# diagnostics

Understand why your CI failed. This GitHub Action collects system and toolchain diagnostics on **macOS and Linux**, with additional Xcode, SDK, and simulator information on macOS.

Diagnostics appear in grouped workflow logs and a job summary. Missing tools, failed commands, and timeouts produce warnings without failing the action. No containers, Node.js, or GitHub token are required.

## Usage

Add diagnostics after your build or test steps:

```yaml
steps:
  - uses: actions/checkout@v6

  - name: Run application tests
    run: swift test

  - name: diagnostics
    if: failure()
    uses: philprime/diagnostics-action@v1
```

Use `if: failure()` to collect diagnostics only after a failed step, or `if: always()` to collect them regardless of earlier step outcomes.

### Xcode destinations

Provide a workspace or project and a scheme to include available build destinations:

```yaml
- name: diagnostics
  if: failure()
  uses: philprime/diagnostics-action@v1
  with:
    workspace: App.xcworkspace
    scheme: App
```

## Inputs

| Input             | Default | Description                                                            |
| ----------------- | ------- | ---------------------------------------------------------------------- |
| `workspace`       | Unset   | Xcode workspace path. Takes precedence over `project`.                 |
| `project`         | Unset   | Xcode project path when no workspace is supplied.                      |
| `scheme`          | Unset   | Scheme used to list destinations. Requires a workspace or project.     |
| `timeout`         | `120`   | Overall diagnostic command budget, in seconds.                         |
| `command-timeout` | `30`    | Per-command limit, in seconds, capped by the remaining overall budget. |

Xcode inputs are ignored on Linux. Paths may be absolute or relative to your checkout directory.

## Documentation

- [Collected diagnostics, runner requirements, and timeout behavior](docs/diagnostics.md)
- [Security and diagnostic log privacy](SECURITY.md)
- [Contributing and local development](CONTRIBUTING.md)
- [Releasing and versioning](docs/releases.md)

## License

See [LICENSE](LICENSE).
