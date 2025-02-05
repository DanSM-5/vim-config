#!/usr/bin/env bash

LINE="$*"
FILE=$(awk -F: '{ print $1 }' <<< "$LINE")
NUMBER=$(awk -F: '{ print $2 }' <<< "$LINE")

if [ -z "$NUMBER" ]; then
  NUMBER=0
fi

# set preview command
if command -v bat &> /dev/null; then
  bat --style="${BAT_STYLE:-numbers}" --color=always --pager=never \
    --highlight-line="$NUMBER" -- "$FILE"
else
  cat -- "$FILE"
fi

