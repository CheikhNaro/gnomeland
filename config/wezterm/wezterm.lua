local wezterm = require 'wezterm'
local act = wezterm.action

local globals_path = wezterm.config_dir .. '/globals.lua'
local themes_path  = wezterm.config_dir .. '/theme.lua'

local globals = dofile(globals_path)
local themes  = dofile(themes_path)

local function active_theme()
  return globals.preview_theme or globals.current_theme
end

----------------------------------------------------------------------
-- SÉLECTEUR DE THÈMES INTERACTIF
----------------------------------------------------------------------

local function theme_switcher(window, pane)
  -- Sauvegarder l'état fullscreen actuel
  local is_fullscreen = window:get_dimensions().is_full_screen

  -- Maximiser si pas déjà en fullscreen
  if not is_fullscreen then
    window:perform_action(act.ToggleFullScreen, pane)
  end

  -- Split avec le sélecteur
  window:perform_action(
    act.SplitPane {
      direction = "Right",
      size = { Percent = 30 },
      command = {
        args = {
          "bash",
          "-c",
          string.format([[
WEZTERM_DIR="%s"

CURRENT_THEME=$(lua -e "
  local g = dofile('$WEZTERM_DIR/globals.lua')
  print(g.current_theme)
")

THEME_LIST=$(lua -e "
  local t = dofile('$WEZTERM_DIR/theme.lua')
  for _, v in ipairs(t) do print(v) end
")

SELECTED=$(echo "$THEME_LIST" | fzf --reverse --exact \
  --prompt="🎨 Theme (current: $CURRENT_THEME) > " \
  --bind "focus:execute-silent:sleep 0.01; lua $WEZTERM_DIR/scripts/preview_theme.lua {}")

if [ -n "$SELECTED" ]; then
  lua "$WEZTERM_DIR/scripts/apply_theme.lua" "$SELECTED"
else
  lua "$WEZTERM_DIR/scripts/cancel_theme.lua"
fi

echo "restore" > /tmp/wezterm_restore_state
          ]],
          wezterm.config_dir
          )
        },
      },
    },
    pane
  )
end

----------------------------------------------------------------------
-- WATCHERS
----------------------------------------------------------------------

wezterm.on('update-status', function(window, pane)
  -- Signal pour déclencher le theme switcher depuis le shell (alias wt)
  local f1 = io.open('/tmp/wezterm_trigger_theme_switcher', 'r')
  if f1 then
    f1:close()
    os.remove('/tmp/wezterm_trigger_theme_switcher')
    theme_switcher(window, pane)
    return
  end

  -- Signal pour restaurer la fenêtre après le sélecteur
  local f2 = io.open('/tmp/wezterm_restore_state', 'r')
  if f2 then
    f2:close()
    os.remove('/tmp/wezterm_restore_state')
    local is_fullscreen = window:get_dimensions().is_full_screen
    if is_fullscreen then
      window:perform_action(act.ToggleFullScreen, pane)
    end
  end
end)

----------------------------------------------------------------------
-- CONFIG PRINCIPALE
----------------------------------------------------------------------

return {

  window_background_opacity = 0.95,
  window_close_confirmation = "NeverPrompt",

  initial_cols = 85,
  initial_rows = 25,
  adjust_window_size_when_changing_font_size = false,
  window_decorations = "NONE",
  window_frame = {
    --border_left_width = '2px',
    --border_right_width = '2px',
    --border_bottom_height = '2px',
    --border_top_height = '2px',
    --border_left_color = 'white',
    --border_right_color = 'white',
    --border_bottom_color = 'white',
    --border_top_color = 'white',
  },

  font = wezterm.font_with_fallback({
    { family = "JetBrainsMono Nerd Font", weight = "Bold" },
    { family = "Noto Sans Symbols 2" },
    { family = "Noto Sans" },
    { family = "Noto Sans CJK SC" },
  }),
  font_size = 12,

  xcursor_theme = "volantes",
  xcursor_size = 48,
  hide_mouse_cursor_when_typing = false,

  default_cursor_style = "BlinkingBlock",
  cursor_blink_rate = 200,
  cursor_blink_ease_in = "Constant",
  cursor_blink_ease_out = "Constant",

  scrollback_lines = 10000,
  animation_fps = 1,
  mouse_wheel_scrolls_tabs = false,

  enable_tab_bar = true,
  hide_tab_bar_if_only_one_tab = true,
  tab_bar_at_bottom = true,
  use_fancy_tab_bar = false,

  enable_wayland = true,

  keys = {
    {
      key = "T",
      mods = "CTRL|SHIFT",
      action = wezterm.action_callback(theme_switcher),
    },
    { key = "i", mods = "ALT", action = act.IncreaseFontSize },
    { key = "o", mods = "ALT", action = act.DecreaseFontSize },
    { key = "0", mods = "CTRL", action = act.ResetFontSize },
    { key = "c", mods = "CTRL", action = act.CopyTo "Clipboard" },
    { key = "v", mods = "CTRL", action = act.PasteFrom "Clipboard" },
    { key = "t", mods = "CTRL", action = act.SpawnCommandInNewTab { cwd = wezterm.home_dir } },
    { key = "PageUp", mods = "CTRL", action = act.ActivateTabRelative(-1) },
    { key = "PageDown", mods = "CTRL", action = act.ActivateTabRelative(1) },
    { key = "Q", mods = "CTRL|SHIFT", action = act.CloseCurrentTab { confirm = false } },
    { key = "Enter", mods = "CTRL|SHIFT", action = act.SplitHorizontal { domain = "CurrentPaneDomain" } },
    { key = "]", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection "Next" },
    { key = "[", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection "Prev" },
    { key = "k", mods = "SUPER", action = act.SpawnWindow },
    { key = "f", mods = "CTRL", action = act.Search { CaseInSensitiveString = "" } },
    { key = "C", mods = "CTRL|SHIFT", action = act.SendKey { key = "c", mods = "CTRL" } },
  },

  window_padding = { left = 0 },

  color_scheme = active_theme(),
}
