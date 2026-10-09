#!/usr/bin/env bash

set -euo pipefail

root_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

docker build -t devops-tool "$root_dir"
docker run --rm devops-tool help
docker run --rm devops-tool system-info

if docker run --rm devops-tool invalid-command; then
  printf 'Docker smoke test failed: invalid command unexpectedly succeeded.\n' >&2
  exit 1
else
  status=$?
  if ((status != 2)); then
    printf 'Docker smoke test failed: invalid command returned %s, expected 2.\n' "$status" >&2
    exit 1
  fi
fi

printf 'Docker build and smoke tests passed.\n'
