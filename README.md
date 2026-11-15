# diagnostics

Understand why your CI failed. This GitHub Action collects system and toolchain diagnostics on **macOS and Linux**, with additional Xcode, SDK, and simulator information on macOS.

Diagnostics appear in grouped workflow logs and a job summary. Missing tools and failed commands produce warnings without failing the action. No containers, Node.js, or GitHub token are required.

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
    timeout-minutes: 2
```

Use `if: failure()` to collect diagnostics only after a failed step, or `if: always()` to collect them regardless of earlier step outcomes. Set GitHub's `timeout-minutes` on the step to limit its execution time.

## Documentation

- [Collected diagnostics, runner requirements, and timeout behavior](docs/diagnostics.md)
- [Security and diagnostic log privacy](SECURITY.md)
- [Contributing and local development](CONTRIBUTING.md)
- [Releasing and versioning](docs/releases.md)

## License

See [LICENSE](LICENSE).
