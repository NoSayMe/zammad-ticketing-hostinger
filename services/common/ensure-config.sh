#!/bin/sh
set -e
# Usage: ensure-config.sh <template> <target> [vars]
TEMPLATE="$1"
TARGET="$2"
shift 2
VARS="$*"

if [ ! -f "$TARGET" ]; then
  echo "Generating $TARGET from $(basename "$TEMPLATE")"
  if [ -n "$VARS" ]; then
    envsubst "$VARS" < "$TEMPLATE" > "$TARGET"
  else
    cp "$TEMPLATE" "$TARGET"
  fi
else
  echo "Using existing $TARGET"
fi
