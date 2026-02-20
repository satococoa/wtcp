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
