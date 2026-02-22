# wtcp quick recipes

This document contains practical patterns for using `wtcp` in day-to-day git worktree workflows.

---

## 1) Copy local env/config into a new worktree

Common examples:

```bash
wtcp .env
wtcp .tool-versions
wtcp config/local.yml
```

Tip: start with dry-run if you’re not sure the path is correct.

```bash
wtcp --dry-run .env config/local.yml
```

---

## 2) Copy a directory to skip reinstalling dependencies

Examples (choose what makes sense for your stack):

```bash
wtcp node_modules
wtcp vendor/bundle
wtcp Pods
wtcp .venv
```

Notes:
- Copying big directories can still take time, but it’s often faster than reinstalling.
- Prefer copying the minimal directory you actually need.

---

## 3) Copy multiple paths at once

```bash
wtcp .env scripts/setup.sh config/
```

---

## 4) When auto-detection fails: provide --from

If `wtcp` can’t detect the main worktree, pass the main repo root explicitly:

```bash
wtcp --from ../my-repo-main .env
```

---

## 5) Overwriting: only when you really mean it

Default behavior refuses overwrites.

If you truly want to overwrite:

```bash
wtcp --force config/app.yml
```

Safer pattern:

```bash
wtcp --dry-run config/app.yml
wtcp --force config/app.yml
```

---

## 6) Validate paths are repo-root-relative

✅ OK:

- `README.md`
- `config/app.yml`
- `scripts/setup.sh`
- `dirA/`

❌ Rejected:

- `/tmp/secret` (absolute path)
- `../secret` (parent traversal)
- `a/../b` (contains a `..` segment)
