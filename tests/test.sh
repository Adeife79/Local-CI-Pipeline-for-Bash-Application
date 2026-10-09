#!/usr/bin/env bash

set -euo pipefail

root_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
app="$root_dir/app/app.sh"
passed=0
failed=0

run_test() {
  local name=$1
  shift

  if "$@"; then
    printf 'PASS: %s\n' "$name"
    ((passed += 1))
  else
    printf 'FAIL: %s\n' "$name" >&2
    ((failed += 1))
  fi
}

expect_success() {
  local output
  output=$("$@" 2>&1) || return 1
  [[ -n $output ]]
}

expect_failure() {
  local expected_status=$1
  shift
  local output
  local actual_status=0

  output=$("$@" 2>&1) || actual_status=$?
  [[ $actual_status -eq $expected_status && -n $output ]]
}

expect_output_contains() {
  local expected=$1
  shift
  local output
  output=$("$@" 2>&1) || return 1
  [[ $output == *"$expected"* ]]
}

run_test 'help displays usage' expect_output_contains 'Usage:' "$app" help
run_test 'system-info reports a hostname' expect_output_contains 'Hostname:' "$app" system-info
run_test 'invalid command exits with status 2' expect_failure 2 "$app" unknown
run_test 'missing host exits with status 2' expect_failure 2 "$app" check-host
run_test 'empty host exits with status 2' expect_failure 2 "$app" check-host ''
run_test 'localhost resolves successfully' expect_output_contains 'resolves successfully' "$app" check-host localhost
run_test 'missing port arguments exit with status 2' expect_failure 2 "$app" check-port localhost
run_test 'non-numeric port exits with status 2' expect_failure 2 "$app" check-port localhost abc
run_test 'zero port exits with status 2' expect_failure 2 "$app" check-port localhost 0
run_test 'port above range exits with status 2' expect_failure 2 "$app" check-port localhost 65536
run_test 'very large port exits with status 2' expect_failure 2 "$app" check-port localhost 999999999999999999999

printf '\n%d tests passed; %d failed.\n' "$passed" "$failed"
((failed == 0))
