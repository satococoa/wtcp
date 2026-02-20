# wtcp

`wtcp` is a small shell tool that copies files/directories from a main worktree into the current Git worktree.

## Features

- Copy one or more paths from source worktree to current worktree
- Auto-detect source root from `git worktree list --porcelain`
- `--from` override for explicit source root
- `--dry-run` mode
- Safe-by-default behavior (refuses overwrite unless `--force`)

## Requirements

- `bash`
- `git`
- `rsync`

## Installation

### Homebrew

```bash
brew tap satococoa/tap
brew install wtcp
```

### Local install

```bash
make install PREFIX="$HOME/.local"
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
```

### Run directly from this repository

```bash
./bin/wtcp --help
```

## Test

```bash
make test
```

Notes:

- `bin/wtcp` is compatible with macOS default `/bin/bash` (3.2).
- `test/test_wtcp.sh` is also compatible with macOS default `/bin/bash` (3.2).

## Usage

```bash
wtcp [--from <dir>] [--dry-run|-n] [--force|-f] <path>...
```

Examples:

```bash
wtcp README.md
wtcp config/ scripts/setup.sh
wtcp --dry-run .github/workflows/ci.yml
wtcp --from ../repo-main --force config/application.yml
```

## Behavior Notes

- Paths are treated as repository-root relative paths.
- Absolute paths and parent traversal segments (`..`) are rejected.
- Without `--force`, existing destinations are not overwritten.

## License

MIT. See [LICENSE](./LICENSE).
