#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$script_dir"
home_dir="$HOME"

echo "Installing gnomeland dotfiles from $repo_root into $home_dir"

# copy themes
if [ -d "$repo_root/themes" ]; then
  mkdir -p "$home_dir/.themes"
  rsync -a --delete "$repo_root/themes/" "$home_dir/.themes/"
fi

# copy icons
if [ -d "$repo_root/icons" ]; then
  mkdir -p "$home_dir/.icons"
  rsync -a --delete "$repo_root/icons/" "$home_dir/.icons/"
fi

# copy config
if [ -d "$repo_root/config" ]; then
  mkdir -p "$home_dir/.config"
  rsync -a --delete "$repo_root/config/" "$home_dir/.config/"
fi

# Replace hardcoded paths in destination (only text files)
echo "Patching occurrences of /home/akhi-yucef to $home_dir in copied files..."
for d in "$home_dir/.config" "$home_dir/.themes" "$home_dir/.icons"; do
  if [ -d "$d" ]; then
    # list text files containing the string; ignore binary files
    grep -RIIl --binary-files=without-match "/home/akhi-yucef" "$d" || true | while read -r f; do
      printf "Patching %s\n" "$f"
      sed -i "s|/home/akhi-yucef|$home_dir|g" "$f" || true
    done
  fi
done

# Load GNOME extension settings with dconf
ext_dir="$repo_root/extensions-settings"
if [ -d "$ext_dir" ]; then
  if ! command -v dconf >/dev/null 2>&1; then
    echo "dconf not found. Install dconf-editor (e.g., sudo apt install dconf-editor) to load extension settings."
    exit 1
  fi
  mkdir -p "$home_dir/.config/dconf-backups"
  for f in "$ext_dir"/*.conf; do
    [ -e "$f" ] || continue
    name="$(basename "$f" .conf)"
    # Heuristic: load into /org/gnome/shell/extensions/<name>/
    target="/org/gnome/shell/extensions/$name/"
    echo "Backing up current keys from $target to $home_dir/.config/dconf-backups/${name}.dconf"
    dconf dump "$target" > "$home_dir/.config/dconf-backups/${name}.dconf" || true
    echo "Loading $f -> $target"
    if ! dconf load "$target" < "$f"; then
      echo "Failed to load $f into $target — you may need to inspect the file and load manually."
    fi
  done
fi

# Create autostart desktop entry for sync-theme.sh if it exists in the copied config
sync_script_dir="$home_dir/.config/sync-theme"
sync_script="$sync_script_dir/sync-theme.sh"
if [ -f "$sync_script" ]; then
  mkdir -p "$home_dir/.config/autostart"
  desktop_file="$home_dir/.config/autostart/sync-theme.desktop"
  cat > "$desktop_file" <<EOF
[Desktop Entry]
Hidden=false
Name=sync-theme
Comment=
Terminal=false
Exec=/bin/bash "$sync_script"
Type=Application
EOF
  echo "Created autostart desktop entry: $desktop_file"
else
  echo "No sync-theme.sh found at $sync_script — skipping autostart creation."
fi


echo "Install complete. You may need to restart GNOME Shell (Alt+F2, then r) or log out/in for all changes to take effect."
