#!/usr/bin/env bash

[[ -v debug ]] && set -x

# Helper for FzfBuffers
# This script caches the bufnrs to delete when fzf terminal window closes

# Tempfile with current line selected
selected="$1"
# Tempfile with content displayed in fzf
opened_buffers="$2"
# Tempfile that list bufnrs to remove
remove_list="$3"
# Temporary cache
# buff="$(mktemp)"

# Find bufnr inside square brackets
# "filename linenumber [bufnr] somesymbol? buffname"
bufnr="$(sed 's/\x1b\[[0-9;]*[mGKHF]//g' "$selected" | sed -nE 's|.*\[([0-9]+)\].*|\1|p')"

# Ensure files exist
touch "$opened_buffers"
touch "$remove_list"

# Get line of the selected buffer
# First clean ansi color escapes, then find the line that matches the bufnr
line="$(sed 's/\x1b\[[0-9;]*[mGKHF]//g' "$opened_buffers" | awk -v toremove="[$bufnr]" '$3 == toremove { print NR }')"

# Filter out buffer to remove
# awk -v toremove="$line" 'NR != toremove { print $0 }' "$opened_buffers" > "$buff"
# Store selected line for future removal
echo "$bufnr" >> "$remove_list"

# Remove outdated temp_file
# rm -f "$opened_buffers"
# Substitute with new updated buffer
# mv "$buff" "$opened_buffers"

