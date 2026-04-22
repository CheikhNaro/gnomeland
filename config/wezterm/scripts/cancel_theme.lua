local globals_path = os.getenv("HOME") .. "/.config/wezterm/globals.lua"
local globals = dofile(globals_path)

local f = io.open(globals_path, "w")
f:write("return {\n")
f:write(string.format('  current_theme = "%s",\n', globals.current_theme))
f:write("  preview_theme = nil,\n")
f:write("}\n")
f:close()

