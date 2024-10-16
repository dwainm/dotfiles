#!/bin/sh

# The $NAME variable is passed from sketchybar and holds the name of
# the item invoking this script:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting
sketchybar --set "$NAME" label="$(gcalcli agenda --nocolor --nostarted --details title | head -2  | tail -1 | sed -r "s/Wed|Mon|Tue|Thu|Fri|Sat|Sun//" | sed -r "s/Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec//" | sed -r 's/[^[:print:]]//g' | sed -r 's/\[0m\[0m//')" \
