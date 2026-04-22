Gnomeland — Dotfiles for GNOME

This repository contains themes, icons and GNOME settings (dconf) to personalize a GNOME desktop environment.

## Essential Dependencies

### GNOME Extensions
- **ArcMenu**: [https://extensions.gnome.org/extension/3628/arcmenu/](https://extensions.gnome.org/extension/3628/arcmenu/)
- **Appindicator**: [https://extensions.gnome.org/extension/615/appindicator-support/](https://extensions.gnome.org/extension/615/appindicator-support/)
- **Auto Accent color**: [https://extensions.gnome.org/extension/7502/auto-accent-colour/](https://extensions.gnome.org/extension/7502/auto-accent-colour/)
- **Color picker**: [https://extensions.gnome.org/extension/3396/color-picker/](https://extensions.gnome.org/extension/3396/color-picker/)
- **Just perfection**: [https://extensions.gnome.org/extension/3843/just-perfection/](https://extensions.gnome.org/extension/3843/just-perfection/)
- **Overview Background**: [https://extensions.gnome.org/extension/5856/overview-background/](https://extensions.gnome.org/extension/5856/overview-background/)
- **Static Workspace background**: [https://extensions.gnome.org/extension/8505/static-workspace-background/](https://extensions.gnome.org/extension/8505/static-workspace-background/)
- **Top Bar Organizer**: [https://extensions.gnome.org/extension/4356/top-bar-organizer/](https://extensions.gnome.org/extension/4356/top-bar-organizer/)
- **Unblank lock screen**: [https://extensions.gnome.org/extension/1414/unblank/](https://extensions.gnome.org/extension/1414/unblank/)
- **Unite**: [https://github.com/hardpixel/unite-shell](https://github.com/hardpixel/unite-shell)
- **User theme**: [https://extensions.gnome.org/extension/19/user-themes/](https://extensions.gnome.org/extension/19/user-themes/)

### Packages
- **dconf-editor**
- **wlogout**
- **ignition**: `flatpak install flathub io.github.flattool.Ignition`

## Installation

1. Clone this repository:

   ```bash
   git clone https://github.com/CheikhNaro/gnomeland.git
   cd gnomeland
   ```

2. Make the installer executable and run it:

   ```bash
   chmod +x install-dotfiles.sh
   ./install-dotfiles.sh
   ```

## Customization

The look and feel of the windows and the top bar are tailored to my personal preference:

- Windows without title bars.
- Borderless windows and square corners (no rounded corners).
- Windows without control buttons (minimize, maximize, close).

You are free to modify this look by editing the "unite" section in the `gtk.css` files located in `config/gtk-3.0/` and `config/gtk-4.0/`.

**Example:** To add rounded corners, change `border-radius: 0px;` to `15px` or `20px` in the `decoration, window, ...` block.

### Keyboard Shortcuts
- **ArcMenu Launcher**: Press `Alt + Space` to trigger the menu.

### Marble Shell Theme
You can also create your own Marble-shell theme with custom colors. Detailed instructions can be found in the original repository: [https://github.com/imarkoff/Marble-shell-theme](https://github.com/imarkoff/Marble-shell-theme)

## Contributing

Contributions are welcome. Open an issue or pull request on GitHub.
