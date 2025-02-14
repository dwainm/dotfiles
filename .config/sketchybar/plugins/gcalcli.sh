#!/bin/bash

# Get the next event for the main display
NEXT_EVENT=$(~/bin/upcomming_calendar_events_gcalcli)

# Update main calendar item
sketchybar --set $NAME label="$NEXT_EVENT"

# Get upcoming events after next
IFS=$'\n' read -r -d '' -a EVENT_ARRAY < <(~/bin/upcoming_calendar_events_after_next && printf '\0')

# Set first event (array index starts at 0)
if [ ${#EVENT_ARRAY[@]} -gt 0 ]; then
    sketchybar --set calendar.event1 label="${EVENT_ARRAY[0]}"
else
    sketchybar --set calendar.event1 label="No upcoming events"
fi

# Set second event
if [ ${#EVENT_ARRAY[@]} -gt 1 ]; then
    sketchybar --set calendar.event2 label="${EVENT_ARRAY[1]}"
else
    sketchybar --set calendar.event2 label="No more events"
fi
