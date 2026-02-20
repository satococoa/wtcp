# AGENTS.md

This repository contains `wtcp`, a small shell utility for copying files/directories from the main Git worktree into the current worktree.

## Basics

- Main script: `bin/wtcp`
- Tests: `test/test_wtcp.sh`
- Test command: `make test`

## Bash Compatibility

- `bin/wtcp` is compatible with macOS default `/bin/bash` 3.2.
- `test/test_wtcp.sh` is also compatible with macOS default `/bin/bash` 3.2.

## Development Notes

- Keep script changes POSIX/Bash-3.2-friendly unless there is a strong reason not to.
- Prefer explicit checks for `git` and `rsync` availability.
- For path handling, reject absolute paths and `..` path segments.

## Release Process

- Homebrew formula updates are automated from tags via `.github/workflows/release.yml`.
- Required secret in `satococoa/wtcp`: `HOMEBREW_TAP_GITHUB_TOKEN` (must have push access to `satococoa/homebrew-tap`).
- Release steps:
  1. Ensure `main` is up to date and CI is green.
  2. Create and push a tag: `git tag vX.Y.Z && git push origin vX.Y.Z`
  3. Create GitHub release: `gh release create vX.Y.Z --title vX.Y.Z --notes "<notes>"`
  4. Confirm `release.yml` succeeded and `satococoa/homebrew-tap` got an auto-commit updating `wtcp.rb`.
