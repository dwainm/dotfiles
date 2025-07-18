#!/bin/bash
# Kill existing Karabiner processes and start kanata
sudo pkill -f karabiner 2>/dev/null
nohup sudo /opt/homebrew/bin/kanata --cfg /Users/dwain/.config/kanata/kanata.kbd --nodelay > /tmp/kanata.log 2>&1 &