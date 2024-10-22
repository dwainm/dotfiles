#!/bin/bash

TIME=$(osascript -e 'tell application "Flow" to getTime')
PHASE=$(osascript -e 'tell application "Flow" to getPhase') 
TASK=$(osascript -e 'tell application "Flow" to getTitle') 

SHOW=$PHASE
if [ $PHASE = "Flow" ]; then
	SHOW=$TASK
	COLOR=0xFFA6D189
elif [ $PHASE = "Break" ] || [ $PHASE = "Long Break" ]; then
	COLOR=0xFFE78284
fi


sketchybar --set $NAME label="$TIME $SHOW" icon="󰄉" icon.color=$COLOR
