#!/usr/bin/env bash
# Splits the `args` input into arguments without running it through the shell.
#
# Supports single quotes, double quotes, backslash escapes, and line
# continuations, so `--dart-define="A=b c"` is one argument. Never expands
# `$VAR`, `$(...)`, or backticks, and never interprets `;`, `&`, `|`, `<`,
# `>`, `(`, `)`, or `#`. Inputs whose meaning would differ from shell parsing
# fail loudly instead of passing a different value.
#
# Usage: parse_args "$ARGS"; then use "${PARSED_ARGS[@]}".
# Compatible with bash 3.2 (macOS /bin/bash).

parse_args() {
  local input="$1"
  local n=${#input}
  local i=0 c next quote='' token='' in_token=false
  PARSED_ARGS=()

  while ((i < n)); do
    c="${input:i:1}"
    next="${input:i+1:1}"
    if [[ "$quote" == "'" ]]; then
      if [[ "$c" == "'" ]]; then quote=''; else token+="$c"; fi
    elif [[ "$quote" == '"' ]]; then
      case "$c" in
        '"') quote='' ;;
        '\')
          case "$next" in
            '"' | '\' | '$' | '`') token+="$next"; i=$((i + 1)) ;;
            $'\n') i=$((i + 1)) ;;
            *) token+="$c" ;;
          esac
          ;;
        '$' | '`') _parse_args_expansion_error "$c"; return 1 ;;
        *) token+="$c" ;;
      esac
    else
      case "$c" in
        ' ' | $'\t' | $'\n')
          if $in_token; then
            PARSED_ARGS+=("$token")
            token=''
            in_token=false
          fi
          ;;
        "'" | '"') quote="$c"; in_token=true ;;
        '\')
          if [[ "$next" == $'\n' ]]; then
            i=$((i + 1))
          elif [[ -z "$next" ]]; then
            echo "::error::inputs.args ends with a backslash." >&2
            return 1
          else
            token+="$next"
            in_token=true
            i=$((i + 1))
          fi
          ;;
        '$' | '`') _parse_args_expansion_error "$c"; return 1 ;;
        ';' | '&' | '|' | '<' | '>' | '(' | ')')
          echo "::error::inputs.args contains an unquoted '$c', which is not passed to shorebird. Quote it if it is part of a value (e.g. --dart-define=\"URL=https://x?a=1&b=2\")." >&2
          return 1
          ;;
        '#')
          if ! $in_token; then
            echo "::error::inputs.args contains '#' at the start of an argument. Quote it if it is part of a value." >&2
            return 1
          fi
          token+="$c"
          ;;
        *) token+="$c"; in_token=true ;;
      esac
    fi
    i=$((i + 1))
  done

  if [[ -n "$quote" ]]; then
    echo "::error::inputs.args has an unterminated $quote quote." >&2
    return 1
  fi
  if $in_token; then PARSED_ARGS+=("$token"); fi
}

_parse_args_expansion_error() {
  echo "::error::inputs.args contains '$1', but args are not expanded by the shell. Use a \${{ }} expression (e.g. \${{ github.sha }} or \${{ env.MY_VAR }}) to insert values, or single-quote a literal '$1'." >&2
}
