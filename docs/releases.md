# Releases

## Choosing a version

Consumers can use a full-version tag such as `v1.2.3`, a major-version alias such as `v1`, or a full release commit SHA.

- Full-version tags identify specific releases and are never replaced by the release workflow.
- Major-version aliases point to the latest release published for that major. No separate GitHub release is attached to an alias.
- Full commit SHAs provide immutable references. Consumers using them must update their pins to receive fixes.
- Breaking interface or default-behavior changes require a new major version.

## Publishing

In GitHub, open **Actions → Release → Run workflow**, select `main`, and supply a stable version without a `v` prefix, such as `1.0.0`. Choose increasing release versions. Do not create or push release tags manually.

The [release workflow](../.github/workflows/release.yml) validates the version, runs reusable CI against the exact dispatch commit, creates the full-version tag, publishes a GitHub release with generated notes, and updates the major-version alias. Existing full-version tags and noncanonical or prerelease versions are rejected.

Only the publishing job receives `contents: write`. No personal token or GitHub App credentials are required. Concurrent publishing is serialized.

If publishing partially fails, inspect the existing release and aliases before recovery. The workflow deliberately refuses to replace an existing full-version tag. Publishing the first release and any GitHub Marketplace listing are separate maintainer actions. The workflow does not publish to the Marketplace automatically.

## Repository protection

Configure these settings on GitHub:

- Enable immutable releases so published full-version tags and their release assets are locked.
- Protect `main` with pull-request review and the CI **Required checks** status. This aggregate check verifies normal tests and the intentionally failing integration job, so the expected failure cannot hide a regression.
- Restrict full-version tag creation to the release process, and prohibit updates and deletion of `v*.*.*` tags. Keep major-version aliases movable by the publishing workflow.
- Enable private vulnerability reporting and restrict workflow changes to trusted maintainers.
- Keep the default workflow token read-only, allowing the explicit publishing job to request write access.

See [Contributing](../CONTRIBUTING.md) for local setup and checks, and [Security](../SECURITY.md) for vulnerability reporting.
