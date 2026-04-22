#!/usr/bin/env bash
# ~/.config/wezterm/scripts/wezthemes.sh
# Déclenche le sélecteur de thèmes WezTerm via le keybinding Ctrl+Shift+T
# Compatible Fedora / GNOME / Wayland avec wtype

set -euo pipefail

# ==============================================================================
# CONFIG
# ==============================================================================
readonly WM_CLASS="WezTerm"
readonly KEY_COMBO="ctrl+shift+t"
readonly FOCUS_TIMEOUT=0.2  # secondes, pour laisser le temps au focus Wayland

# ==============================================================================
# FONCTIONS
# ==============================================================================

# Vérifie si nous sommes déjà dans un pane WezTerm
is_inside_wezterm() {
  [[ -n "${WEZTERM_PANE:-}" ]]
}

# Tente de focaliser la fenêtre WezTerm via GNOME Shell (Wayland)
focus_wezterm_gnome() {
  # gdbus appelle du JS dans GNOME Shell pour activer la fenêtre WezTerm
  gdbus call --session \
    --dest org.gnome.Shell \
    --object-path /org/gnome/Shell \
    --method org.gnome.Shell.Eval \
    "global.get_window_actors().forEach(w => {
       let mw = w.get_meta_window();
       if (mw && mw.get_wm_class() === '$WM_CLASS') {
         mw.activate(global.display.get_current_time_roundtrip());
         return true;
       }
     });" >/dev/null 2>&1 || true
  
  # Délai nécessaire car l'activation Wayland est asynchrone
  sleep "$FOCUS_TIMEOUT"
}

# Envoie la combinaison de touches via wtype
send_keybinding() {
  # -M = maintenir, -k = touche, -m = relâcher
  wtype -M ctrl -M shift -k t -m shift -m ctrl
}

# ==============================================================================
# MAIN
# ==============================================================================

main() {
  # Si on n'est pas déjà dans WezTerm, on essaie de le focaliser
  if ! is_inside_wezterm; then
    focus_wezterm_gnome
  fi

  # Envoie le keybinding pour déclencher ton callback Lua
  send_keybinding
}

main "$@"
