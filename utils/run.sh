#!/usr/bin/env bash

out_file="$CMD_OUTPUT"

if [ -z "$out_file" ]; then
  "$@"
else
  "$@" > "$out_file"
fi

