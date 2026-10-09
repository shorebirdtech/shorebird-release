#!/usr/bin/env bash
# Tests for scripts/parse_args.sh. Run: bash test/parse_args_test.sh
set -uo pipefail
source "$(dirname "$0")/../scripts/parse_args.sh"

failures=0

# expect_args <input> <expected argv, each wrapped in []>
expect_args() {
  local actual
  if ! parse_args "$1" 2>/dev/null; then
    echo "FAIL: $(printf %q "$1") errored, expected $2"
    failures=$((failures + 1))
    return
  fi
  actual=''
  if ((${#PARSED_ARGS[@]} > 0)); then actual="$(printf '[%s]' "${PARSED_ARGS[@]}")"; fi
  if [[ "$actual" == "$2" ]]; then
    echo "ok:   $(printf %q "$1") -> $actual"
  else
    echo "FAIL: $(printf %q "$1") -> $actual, expected $2"
    failures=$((failures + 1))
  fi
}

# expect_error <input>
expect_error() {
  local err
  if err="$(parse_args "$1" 2>&1)"; then
    echo "FAIL: $(printf %q "$1") parsed, expected an error"
    failures=$((failures + 1))
  else
    echo "ok:   $(printf %q "$1") -> error: ${err#::error::}"
  fi
}

# Same result as v1.0.0 shell parsing.
expect_args '' ''
expect_args '   ' ''
expect_args '--verbose -- --dart-define=A=b' '[--verbose][--][--dart-define=A=b]'
expect_args '-- --dart-define="A=b"' '[--][--dart-define=A=b]'
expect_args '-- --dart-define="A=b c"' '[--][--dart-define=A=b c]'
expect_args "-- --dart-define=MSG='hi there'" '[--][--dart-define=MSG=hi there]'
expect_args "--dart-define=X='\$HOME'" '[--dart-define=X=$HOME]'
expect_args '--dart-define=X=\$HOME' '[--dart-define=X=$HOME]'
expect_args '--dart-define="X=\$HOME"' '[--dart-define=X=$HOME]'
expect_args '--dart-define="URL=https://x?a=1&b=2"' '[--dart-define=URL=https://x?a=1&b=2]'
expect_args "--dart-define='a;b|c<d>e(f)'" '[--dart-define=a;b|c<d>e(f)]'
expect_args '--dart-define="say \"hi\""' '[--dart-define=say "hi"]'
expect_args "--dart-define=\"A=it's ok\"" "[--dart-define=A=it's ok]"
expect_args '--dart-define=A=b\ c' '[--dart-define=A=b c]'
expect_args '"" x' '[][x]'
expect_args 'a#b' '[a#b]'
expect_args $'--verbose\n--flavor=prod\n' '[--verbose][--flavor=prod]'
expect_args $'--verbose \\\n  --flavor=prod' '[--verbose][--flavor=prod]'
expect_args $'\t--verbose\t' '[--verbose]'
expect_args '--dart-define=JSON={"a":1}' '[--dart-define=JSON={a:1}]'

# Would mean something else to the shell: fail instead of guessing.
expect_error '--dart-define=SHA=$GITHUB_SHA'
expect_error '--dart-define="SHA=$GITHUB_SHA"'
expect_error '--dart-define=X=$(id)'
expect_error '--dart-define=X=`id`'
expect_error '--verbose; echo pwned'
expect_error '--verbose && echo pwned'
expect_error '--verbose | tee log'
expect_error '--verbose > log'
expect_error '--verbose # comment'
expect_error '--dart-define="unterminated'
expect_error "--dart-define='unterminated"
expect_error 'trailing\'

if ((failures > 0)); then
  echo "$failures failure(s)"
  exit 1
fi
echo "all passed"
