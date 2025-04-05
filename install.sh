#!/usr/bin/env bash

# Ref: https://stackoverflow.com/questions/59895/how-do-i-get-the-directory-where-a-bash-script-is-located-from-within-the-script
SOURCE=${BASH_SOURCE[0]}
while [ -L "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
  SOURCE=$(readlink "$SOURCE")
  [[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done

# Find current install location
location=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )

if ! [ -f "$location/autoload/plug.vim" ]; then
  # Install VimPlug
  curl -fLo "$location/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

symlink_locations=(
  "$HOME/.vim"
  "$HOME/.config/nvim"
)

# Replace for vim and nvim
for loc in "${symlink_locations[@]}"; do
  # replace directory if exist
  [ -d "$loc" ] && mv "$loc" "$loc.bac"
  [ -L "$loc" ] && continue
  [ -f "$loc" ] && rm "$loc"

  ln -s "$location" "$loc"
done

# Nvim from scoop reads from APPDATA
if [ -n "$LOCALAPPDATA" ]; then
  appdata="${LOCALAPPDATA//\\//}"
  nvim="$appdata/nvim"
  # replace directory if exist
  [ -d "$nvim" ] && mv "$nvim" "$nvim.bac"
  [ -L "$nvim" ] && exit
  [ -f "$nvim" ] && rm "$nvim"

  ln -s "$location" "$nvim"
fi

