#!/usr/bin/env bash

set -eu

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
repo_root="$(CDPATH= cd -- "${script_dir}/.." && pwd)"

cd "${repo_root}"

printf '%s\n' '# ZEROON repository context'
printf 'generated_at: %s\n' "$(date '+%Y-%m-%d %H:%M:%S %z')"
printf 'repo_root: %s\n' "${repo_root}"
printf 'branch: %s\n' "$(git branch --show-current || true)"
printf 'head: %s\n' "$(git rev-parse --short=12 HEAD)"

upstream="$(git rev-parse --abbrev-ref '@{upstream}' 2>/dev/null || true)"
if [ -n "${upstream}" ]; then
  counts="$(git rev-list --left-right --count "${upstream}...HEAD")"
  behind="$(printf '%s' "${counts}" | awk '{print $1}')"
  ahead="$(printf '%s' "${counts}" | awk '{print $2}')"
  printf 'upstream: %s (ahead=%s behind=%s)\n' \
    "${upstream}" "${ahead}" "${behind}"
else
  printf '%s\n' 'upstream: none'
fi

printf '\n%s\n' '## Working tree'
status="$(git status --short --branch)"
printf '%s\n' "${status}"

printf '\n%s\n' '## Recent commits'
git log -5 --date=short --pretty=format:'%h %ad %s'
printf '\n'

printf '\n%s\n' '## Documented execution snapshot'
if [ -f CURRENT_STATE.md ]; then
  awk '
    /^## Execution Snapshot$/ { printing = 1; next }
    printing && /^## / { exit }
    printing && NF { print }
  ' CURRENT_STATE.md
else
  printf '%s\n' 'CURRENT_STATE.md missing'
fi

printf '\n%s\n' '## Safety note'
printf '%s\n' \
  'This snapshot does not read environment files, secrets, or production data.'
