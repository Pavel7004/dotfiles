#!/usr/bin/env bash

function getProgressString {
    ITEMS="$1" # The total number of items(the width of the bar)
    FILLED_ITEM="$2" # The look of a filled item 
    NOT_FILLED_ITEM="$3" # The look of a not filled item
    STATUS="$4" # The current progress status in percent

    # calculate how many items need to be filled and not filled
    FILLED_ITEMS=$(echo "((${ITEMS} * ${STATUS})/100 + 0.5) / 1" | bc)
    NOT_FILLED_ITEMS=$(echo "$ITEMS - $FILLED_ITEMS" | bc)

    # Assemble the bar string
    msg=$(printf "%${FILLED_ITEMS}s" | sed "s| |${FILLED_ITEM}|g")
    msg=${msg}$(printf "%${NOT_FILLED_ITEMS}s" | sed "s| |${NOT_FILLED_ITEM}|g")
    
    echo "$msg"
}

# Arbitrary but unique message id
msgId="991049"

# Change the volume

if [[ $1 == "toggle" ]]; then
    pactl set-sink-mute 0 toggle > /dev/null
else
    pactl set-sink-volume 0 "$1" > /dev/null
fi

# Query amixer for the current volume and whether or not the speaker is muted
volume="$( pactl list sinks | grep '^[[:space:]]Громкость:' | head -n 1 | tail -n 1 | sed -e 's,.* \([0-9][0-9]*\)%.*,\1,')"
mute="$(pactl list sinks | grep '^[[:space:]]Звук выключен:' | sed 's/^[[:space:]]Звук выключен: //')"
if [[ $volume == 0 || $mute == "да" ]]; then
    # Show the sound muted notification
    dunstify -a "changeVolume" -u low -i audio-volume-muted -r "$msgId" "Volume muted" 
else
    # Show the volume notification
    dunstify -a "changeVolume" -u low -i audio-volume-high -r "$msgId" \
    "Volume: ${volume}%" "$(getProgressString 10 "<b> </b>" " " $volume)"
fi

# Play the volume changed sound
canberra-gtk-play -i audio-volume-change -d "changeVolume"
