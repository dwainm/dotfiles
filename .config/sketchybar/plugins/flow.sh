#!/bin/bash

TIME=$(osascript -e 'tell application "Flow" to getTime')
PHASE=$(osascript -e 'tell application "Flow" to getPhase') 
TASK=$(icalBuddy -ic dwain.maralack@a8c.com eventsNow | gsed 's/(.*)//' | gsed -e 's/•//' | head -1 )

osascript -  "$TASK"  <<EOF
on run argv -- argv is a list of strings
    tell application "Flow"
        setTitle to argv 
    end tell
end run
EOF

SHOW=$PHASE
if [ $PHASE = "Flow" ]; then
	SHOW=$TASK
	COLOR=0xFFA6D189
elif [ $PHASE = "Break" ] || [ $PHASE = "Long Break" ]; then
	COLOR=0xFFE78284
fi


sketchybar --set $NAME label="$TIME $SHOW" icon="󰄉" icon.color=$COLOR
