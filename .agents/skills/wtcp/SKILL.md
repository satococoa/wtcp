---
name: wtcp
description: >
  Copy repo-root-relative files or directories from the main Git worktree into the
  current worktree using the `wtcp` CLI (rsync). Use this when working with git
  worktrees and you need to bootstrap or sync a worktree by bringing over configs,
  scripts, or dependency folders. Safe by default: refuses overwrite unless --force;
  supports --dry-run.
---

# wtcp Skill

`wtcp` is a small CLI that copies files/directories from the **main Git worktree**
into the **current worktree**.

This skill teaches an agent when and how to use `wtcp` safely and predictably.

---

## When to use this skill

Use this skill when the user asks to:

- Copy/sync a file or directory from the **main** worktree into the **current** worktree
- Bootstrap a new worktree by bringing local-only files (e.g. `.env`, `.tool-versions`, local config)
- Avoid re-installing heavy dependencies by copying a directory (e.g. `node_modules`, `vendor/bundle`, `Pods`, etc.)
- (JP) 「メイン worktree から今の worktree にファイルをコピーしたい」
- (JP) 「worktree 作ったので .env を持ってきたい」「依存ディレクトリをコピーして環境構築を速くしたい」

Do **NOT** use this skill when:

- The repo is not a git worktree / not inside a git repository
- The task requires merging or applying changes across branches (use git, not file copy)
- The intended source is not the main worktree and the user did not provide `--from`

---

## Preconditions & assumptions

- You are inside the **destination** worktree (the worktree you want to copy *into*)
- `wtcp` is available as either:
  - `wtcp` (installed on PATH), or
  - `./bin/wtcp` (when working inside the `satococoa/wtcp` repository)
- `rsync` and `git` are available

---

## Command shape (reference)

```bash
wtcp [--from <dir>] [--dry-run|-n] [--force|-f] <path>...
```

Key rules:

- `<path>` arguments must be **repo-root-relative**
- Absolute paths and parent traversal segments (`..`) are rejected
- Without `--force`, existing destinations are not overwritten

---

## Recommended workflow (agent playbook)

1. **Clarify what to copy** as repo-root-relative paths (one or more).
2. **Prefer dry-run first** unless the user explicitly wants execution without preview:
   - `wtcp --dry-run <path>...`
3. If the preview looks correct, **run the real copy**:
   - `wtcp <path>...`
4. If you get “destination exists”:
   - Do **not** auto-add `--force`.
   - Only use `--force` when the user explicitly wants overwriting and it’s safe.
5. If main worktree auto-detection fails, use `--from`:
   - Find the main worktree repo root path and pass it explicitly:
     - `wtcp --from <main-root> <path>...`

---

## Safety rules

- Never interpolate user input into shell strings. Pass paths as literal arguments.
- Use `--force` only when overwrite is explicitly intended.
- Be careful copying secrets (e.g. `.env`, keys). Copying is fine, but **never print file contents** in logs/chat.
- Avoid copying `.git/` or other internals—use git operations instead.

---

## Examples

```bash
# Copy a single file
wtcp README.md

# Copy multiple paths
wtcp config/ scripts/setup.sh

# Preview what would happen
wtcp --dry-run .github/workflows/ci.yml

# Explicitly specify the source root
wtcp --from ../repo-main --force config/application.yml
```

---

## More details

- Quick recipes: `references/quick-recipes.md`
- Troubleshooting: `references/troubleshooting.md`
