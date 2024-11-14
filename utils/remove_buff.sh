#!/usr/bin/env bash

line="$1"
temp_file="$2"
remove_list="$3"
buff="$(mktemp)"

# cat /tmp/nvim.eduardo/j86QzT/0 | awk '{ $1=""; $2=""; print $0 }' | fzf --ansi --preview "awk -v ignore={n} 'NR != ignore + 1 { print \$0 }' /tmp/nvim.eduardo/j86QzT/0"

# Remove selected line from source
awk -v toremove="$line" 'NR != toremove + 1 { print $0 }' "$temp_file" > "$buff"
# Store selected line for future removal
echo -e "$(awk -v toremove="$line" 'NR == toremove + 1 { print $0 }' "$temp_file")" >> "$remove_list"
# Remove outdated temp_file
rm -f "$temp_file"
# Substitute with new updated buffer
mv "$buff" "$temp_file"

