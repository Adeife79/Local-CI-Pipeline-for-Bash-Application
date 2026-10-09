#!/usr/bin/env bash

set -euo pipefail

root_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
required_files=(
  "$root_dir/README.md"
  "$root_dir/app/app.sh"
  "$root_dir/scripts/lint.sh"
  "$root_dir/scripts/build.sh"
  "$root_dir/tests/test.sh"
  "$root_dir/.github/workflows/ci.yml"
  "$root_dir/Dockerfile"
  "$root_dir/compose.yaml"
  "$root_dir/.dockerignore"
  "$root_dir/grade.sh"
)

for file in "${required_files[@]}"; do
  if [[ ! -f $file ]]; then
    printf 'Missing required file: %s\n' "$file" >&2
    exit 1
  fi
done

for script in "$root_dir"/app/*.sh "$root_dir"/scripts/*.sh "$root_dir"/tests/*.sh "$root_dir/grade.sh"; do
  if [[ ! -x $script ]]; then
    printf 'Script is not executable: %s\n' "$script" >&2
    exit 1
  fi
  bash -n "$script"
done

printf 'Lint passed: required files exist and Bash syntax is valid.\n'
