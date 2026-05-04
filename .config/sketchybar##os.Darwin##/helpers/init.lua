-- Add the sketchybar module to the package cpath
package.cpath = package.cpath .. ";/Users/" .. os.getenv("USER") .. "/.local/share/sketchybar_lua/?.so"

os.execute("make -C $HOME/.config/sketchybar/helpers -q 2>/dev/null || make -C $HOME/.config/sketchybar/helpers")
