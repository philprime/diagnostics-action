# Security

## Reporting vulnerabilities

Report suspected vulnerabilities privately through the repository's **Security → Report a vulnerability** feature. Do not disclose credentials, exploitable details, or sensitive diagnostic logs in a public issue. If private reporting is unavailable, ask the maintainer to enable it without including vulnerability details.

## Supported versions

Security fixes target the latest stable major version. Use its latest patch release, or the corresponding full commit SHA. Older major versions do not have a guaranteed maintenance period.

## Diagnostic logs

The action does not require a GitHub token, dump the environment, or upload artifacts. It omits hardware serial numbers and UUIDs. Command output can still include hostnames, filesystem paths, project metadata, and information about installed tools or services. Review workflow log visibility before using it on sensitive self-hosted runners.

The caller controls project and workspace inputs. Use trusted workflow definitions and pass inputs through action parameters rather than interpolating them into shell commands. The timeout budget limits diagnostic commands, not the rest of the caller's job.

## Release integrity

Full-version tags identify fixed releases. Major-version compatibility aliases are intentionally movable. Consumers requiring immutable references should pin the full release commit SHA and arrange dependency updates.

The release workflow tests its exact commit and never replaces an existing full-version tag. Repository administrators must enable immutable releases and configure branch/tag protection. Private vulnerability reporting and these protection settings are managed on GitHub, not by the action.
