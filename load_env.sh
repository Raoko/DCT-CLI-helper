#!/bin/bash
# Source this file to load .env vars without printing them.
# Usage: source load_env.sh
# Strip comments, blank lines, and leading/trailing whitespace before exporting.
eval "$(grep -v '^\s*#' "$(dirname "${BASH_SOURCE[0]}")/.env" | grep -v '^\s*$' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | sed 's/^/export /')"
