# wtcp troubleshooting

This document maps common `wtcp` error messages to likely causes and fixes.

---

## "wtcp: not inside a git worktree"

Cause:
- You ran `wtcp` outside of a git repository / outside a worktree.

Fix:
- `cd` into the destination worktree (the one you want to copy into) and run again.

---

## "wtcp: failed to detect main worktree; use --from"

Cause:
- `git worktree list --porcelain` did not return a usable main worktree path (or your environment is unusual).

Fix:
- Pass the main worktree repo root explicitly:

```bash
wtcp --from /path/to/main-worktree <path>...
```

---

## "wtcp: missing in source: <path>"

Cause:
- The specified `<path>` does not exist in the source (main) worktree.

Fix:
- Confirm the file/dir exists in the main worktree.
- Ensure you’re using repo-root-relative paths.

---

## "wtcp: invalid path: <path>"

Cause:
- The path is absolute or contains a `..` segment.

Fix:
- Rewrite it as a repo-root-relative path without parent traversal.
  - Example: use `config/app.yml` not `../config/app.yml`.

---

## "wtcp: destination exists (use --force): <path>"

Cause:
- The destination already exists and `wtcp` is safe-by-default.

Fix options:
1. If overwrite is NOT intended: choose a different path or delete the destination manually.
2. If overwrite IS intended: rerun with `--force`:

```bash
wtcp --force <path>
```

Recommended:
- Start with `--dry-run` before overwriting.

---

## "wtcp: source and destination roots are the same"

Cause:
- You are trying to copy from the same worktree into itself (or you set `--from` to the current worktree).

Fix:
- Run `wtcp` from the destination worktree and set `--from` to a different (main) worktree root if needed.

---

## "wtcp: rsync is required" / "wtcp: git is required"

Cause:
- Missing dependency.

Fix:
- Install missing tools (`git`, `rsync`) in your environment.
