#!/bin/bash

# Get the next event for the main display
NEXT_EVENT=$(~/bin/upcomming_calendar_events_gcalcli)

# Update main calendar item
sketchybar --set calendar label="$NEXT_EVENT"

# Ensure popup items exist
sketchybar --add item calendar.header popup.calendar \
           --set calendar.header label="Rest of the day:" \
                                label.font="Hack Nerd Font:Bold:16.0" \
                                label.padding_left=15 \
                                label.padding_right=15 \
                                label.color=0xFFFFFFFF \
                                background.padding_top=5 \
                                background.padding_bottom=5

# Get upcoming events and URLs
EVENTS=$(~/bin/upcoming_calendar_events_after_next)

# Read into array using read instead of mapfile
declare -a EVENT_ARRAY
while IFS=$'\n' read -r line; do
    EVENT_ARRAY+=("$line")
done <<< "$EVENTS"

# Process events in pairs (event text and URL)
count=1
i=0
while [ $i -lt ${#EVENT_ARRAY[@]} ]; do
    event_text="${EVENT_ARRAY[$i]}"
    url="${EVENT_ARRAY[$((i+1))]}"
    
    if [ ! -z "$event_text" ] && [ ! -z "$url" ]; then
        # Create the event item if it doesn't exist
        sketchybar --add item calendar.event$count popup.calendar 2>/dev/null || true
        
        # Set the properties for the event item
        sketchybar --set calendar.event$count \
                  label="$event_text" \
                  label.font="Hack Nerd Font:Regular:14.0" \
                  label.padding_left=15 \
                  label.padding_right=15 \
                  label.color=0xFFFFFFFF \
                  background.padding_top=5 \
                  background.padding_bottom=5 \
                  click_script="open '$url'; sketchybar -m --set calendar popup.drawing=off"
        ((count++))
    fi
    
    # Move to next pair
    ((i+=2))
done

# If no events were found
if [ $count -eq 1 ]; then
    sketchybar --add item calendar.event1 popup.calendar 2>/dev/null || true
    sketchybar --set calendar.event1 label="No upcoming events" \
                                    label.font="Hack Nerd Font:Regular:14.0" \
                                    label.padding_left=15 \
                                    label.padding_right=15 \
                                    label.color=0xFFFFFFFF
    
    sketchybar --add item calendar.event2 popup.calendar 2>/dev/null || true
    sketchybar --set calendar.event2 label="No more events" \
                                    label.font="Hack Nerd Font:Regular:14.0" \
                                    label.padding_left=15 \
                                    label.padding_right=15 \
                                    label.color=0xFFFFFFFF
fi
