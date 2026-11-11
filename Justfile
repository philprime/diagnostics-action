set shell := ["/bin/bash", "-o", "pipefail", "-c"]

# List development commands.
[default]
default:
    @just --list

# Install development tools and Git hooks on macOS.
setup:
    brew bundle
    just install-pre-commit

# Install the pre-commit Git hook.
install-pre-commit:
    pre-commit install

# Run diagnostic behavior tests.
test:
    just test-bash bash

# Run behavior tests with a specific Bash interpreter.
[positional-arguments]
test-bash interpreter:
    "$1" tests/main.test.sh

# Run real Xcode destination checks on macOS without building the fixture.
test-xcode:
    bash tests/xcode.test.sh

# Check shell scripts and workflows.
lint:
    shellcheck scripts/*.sh tests/*.sh
    actionlint

# Format supported files and the Justfile.
format:
    dprint fmt
    just --fmt

# Check formatting without modifying files.
format-check:
    dprint check
    just --fmt --check

# Run all static quality checks.
analyze: lint format-check

# Run static quality checks and behavior tests.
check: analyze test

# Run all pre-commit checks, including action/workflow schema validation.
hooks:
    pre-commit run --all-files
