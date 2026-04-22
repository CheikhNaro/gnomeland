local globals_path = os.getenv("HOME") .. "/.config/wezterm/globals.lua"
local globals = dofile(globals_path)
local theme = arg[1]
if not theme then return end

local f = io.open(globals_path, "w")
f:write("return {\n")
f:write(string.format('  current_theme = "%s",\n', globals.current_theme))
f:write(string.format('  preview_theme = "%s",\n', theme))
f:write("}\n")
f:close()

