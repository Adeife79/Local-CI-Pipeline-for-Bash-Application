#!/usr/bin/env bash

set -u

usage() {
  cat <<'EOF'
Usage:
  app.sh system-info
  app.sh check-host <host>
  app.sh check-port <host> <port>
  app.sh help
EOF
}

invalid() {
  printf 'Error: %s\n' "$1" >&2
  usage >&2
  exit 2
}

check_host() {
  local host=$1

  [[ -n $host ]] || invalid 'host must not be empty'

  if getent hosts "$host" >/dev/null 2>&1; then
    printf 'Host %s resolves successfully.\n' "$host"
    return 0
  fi

  printf 'Host %s could not be resolved.\n' "$host" >&2
  return 1
}

check_port() {
  local host=$1
  local port=$2

  [[ -n $host ]] || invalid 'host must not be empty'
  if [[ ! $port =~ ^[0-9]+$ ]]; then
    invalid 'port must be numeric'
  fi
  local normalized_port=$port
  while [[ ${#normalized_port} -gt 1 && $normalized_port == 0* ]]; do
    normalized_port=${normalized_port#0}
  done
  if ((${#normalized_port} > 5)) || ((normalized_port < 1 || normalized_port > 65535)); then
    invalid 'port must be between 1 and 65535'
  fi

  if timeout 3 bash -c 'echo > /dev/tcp/"$1"/"$2"' _ "$host" "$normalized_port" 2>/dev/null; then
    printf 'TCP connection to %s:%s succeeded.\n' "$host" "$port"
    return 0
  fi

  printf 'TCP connection to %s:%s failed.\n' "$host" "$port" >&2
  return 1
}

if (($# == 0)); then
  invalid 'command is required'
fi

case $1 in
  help|-h|--help)
    (($# == 1)) || invalid 'help does not accept arguments'
    usage
    ;;
  system-info)
    (($# == 1)) || invalid 'system-info does not accept arguments'
    printf 'Hostname: %s\n' "$(hostname)"
    printf 'Operating system: %s\n' "$(uname -s)"
    printf 'Kernel: %s\n' "$(uname -r)"
    ;;
  check-host)
    (($# == 2)) || invalid 'check-host requires exactly one host'
    check_host "$2"
    ;;
  check-port)
    (($# == 3)) || invalid 'check-port requires a host and port'
    check_port "$2" "$3"
    ;;
  *)
    invalid "unknown command: $1"
    ;;
esac
