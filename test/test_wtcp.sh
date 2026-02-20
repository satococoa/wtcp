#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
WTCP="$ROOT_DIR/bin/wtcp"

for cmd in bash git rsync; do
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "missing command: $cmd" >&2
    exit 1
  }
done

failures=0
tests=0

pass() {
  echo "ok: $1"
}

fail() {
  echo "not ok: $1" >&2
  failures=$((failures + 1))
}

run_test() {
  local name="$1"
  shift
  tests=$((tests + 1))
  if "$@"; then
    pass "$name"
  else
    fail "$name"
  fi
}

setup_repo() {
  local tmp repo wt
  tmp="$(mktemp -d /tmp/wtcp-test.XXXXXX)"
  repo="$tmp/repo"
  wt="$tmp/wt-feature"

  mkdir -p "$repo"
  (
    cd "$repo"
    git init -q
    printf 'base\n' > README.md
    mkdir -p config dirA
    printf 'v1\n' > config/app.yml
    printf 'hello\n' > dirA/file.txt
    git add .
    git commit -q -m 'init'
    git branch -M main
    git worktree add -q "$wt" -b feature
  )

  printf '%s\t%s\t%s\n' "$tmp" "$repo" "$wt"
}

test_dry_run_and_copy_new_file() {
  local tmp repo wt out
  IFS=$'\t' read -r tmp repo wt <<EOF
$(setup_repo)
EOF
  trap "rm -rf '$tmp'" RETURN

  printf 'new\n' > "$repo/extras-new.cfg"
  out="$tmp/out.txt"

  (
    cd "$wt"
    "$WTCP" --dry-run --from "$repo" extras-new.cfg > "$out"
    [[ ! -e "$wt/extras-new.cfg" ]]
    grep -q 'would copy:' "$out"
    "$WTCP" --from "$repo" extras-new.cfg >/dev/null
    [[ "$(cat "$wt/extras-new.cfg")" == "new" ]]
  )
}

test_force_overwrite_behavior() {
  local tmp repo wt err rc
  IFS=$'\t' read -r tmp repo wt <<EOF
$(setup_repo)
EOF
  trap "rm -rf '$tmp'" RETURN

  printf 'v2\n' > "$repo/config/app.yml"
  err="$tmp/err.txt"

  (
    cd "$wt"
    set +e
    "$WTCP" --from "$repo" config/app.yml >/dev/null 2>"$err"
    rc=$?
    set -e
    [[ "$rc" -eq 1 ]]
    grep -q 'destination exists' "$err"
    "$WTCP" --from "$repo" --force config/app.yml >/dev/null
    [[ "$(cat "$wt/config/app.yml")" == "v2" ]]
  )
}

test_auto_detect_source_root() {
  local tmp repo wt
  IFS=$'\t' read -r tmp repo wt <<EOF
$(setup_repo)
EOF
  trap "rm -rf '$tmp'" RETURN

  mkdir -p "$repo/extras"
  printf 'auto\n' > "$repo/extras/auto.txt"

  (
    cd "$wt"
    "$WTCP" --dry-run extras/auto.txt >/dev/null
    "$WTCP" extras/auto.txt >/dev/null
    [[ "$(cat "$wt/extras/auto.txt")" == "auto" ]]
  )
}

test_path_validation() {
  local tmp repo wt rc
  IFS=$'\t' read -r tmp repo wt <<EOF
$(setup_repo)
EOF
  trap "rm -rf '$tmp'" RETURN

  printf 'ok\n' > "$repo/foo..bar"

  (
    cd "$wt"
    "$WTCP" --from "$repo" foo..bar >/dev/null
    [[ "$(cat "$wt/foo..bar")" == "ok" ]]

    set +e
    "$WTCP" --from "$repo" ../secret >/dev/null 2>&1
    rc=$?
    set -e
    [[ "$rc" -eq 1 ]]

    set +e
    "$WTCP" --from "$repo" a/../b >/dev/null 2>&1
    rc=$?
    set -e
    [[ "$rc" -eq 1 ]]

    set +e
    "$WTCP" --from "$repo" /tmp/secret >/dev/null 2>&1
    rc=$?
    set -e
    [[ "$rc" -eq 1 ]]
  )
}

run_test "dry-run and copy new file" test_dry_run_and_copy_new_file
run_test "overwrite policy with --force" test_force_overwrite_behavior
run_test "auto detect main worktree source" test_auto_detect_source_root
run_test "path validation" test_path_validation

echo "tests: $tests, failures: $failures"
if [[ "$failures" -gt 0 ]]; then
  exit 1
fi
