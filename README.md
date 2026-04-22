Gnomeland — Dotfiles for GNOME

This repository contains themes, icons and GNOME settings (dconf) to personalize a GNOME desktop environment.

Installation

1. Clone this repository:

   git clone https://github.com/CheikhNaro/gnomeland.git
   cd gnomeland

2. Make the installer executable and run it:

   chmod +x install-dotfiles.sh
   ./install-dotfiles.sh

What the installer does

- Copies themes from themes/ to ~/.themes
- Copies icons from icons/ to ~/.icons
- Copies the contents of config/ to ~/.config
- For each *.conf file in extensions-settings/, the script runs dconf load into /org/gnome/shell/extensions/<name>/ (e.g. arcmenu.conf -> /org/gnome/shell/extensions/arcmenu/). Existing keys are backed up to ~/.config/dconf-backups/.
- If a sync-theme.sh script is present in ~/.config/sync-theme/, the installer creates a ~/.config/autostart/sync-theme.desktop that runs it at login.

Path replacement

The installer searches copied files and replaces exact occurrences of "/home/akhi-yucef" with the current user's $HOME, preventing broken absolute paths.

Notes and alternatives

- dconf load is the standard way to restore dconf dumps. If a .conf needs a different path, edit the script or load manually: dconf load /path/ < file.conf
- Optionally, add a confirmation prompt before each dconf load for safer operation.

Contributing

Contributions are welcome. Open an issue or pull request on GitHub.
