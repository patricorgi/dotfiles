#!/usr/bin/env bash

read UP DOWN <<< "$(transmission-remote -l | awk 'NR>1 {up=$4; down=$5} END {print up, down}')"
NUMBERS=($UP $DOWN)

# Number formatting. Thanks, ChatGPT!
for ((i=0; i<${#NUMBERS[@]}; i++)); do
    CURRENT_NUMBER=${NUMBERS[i]}

    # Check if the number is greater than 999
    if (( $(echo "$CURRENT_NUMBER > 999" | bc -l) )); then
        FORMATTED_NUMBER=$(echo "scale=1; $CURRENT_NUMBER / 1000" | bc -l)
        SUFFIX="MB"
    else
        FORMATTED_NUMBER=$(echo "scale=1; $CURRENT_NUMBER" | bc -l)
        SUFFIX="KB"
    fi

    # Remove the decimal point if it's zero
    if [[ $FORMATTED_NUMBER == *".0" ]]; then
        FORMATTED_NUMBER=${FORMATTED_NUMBER%".0"}
    fi

    # Create a new variable dynamically
    NEW_VARIABLE="FORMATTED_NUMBER_$i"
    declare "$NEW_VARIABLE=$FORMATTED_NUMBER$SUFFIX"
done

if [[ "$UP" == "0.0" && "$DOWN" == "0.0" ]]; then
  args+=(background.color=0x40eeeeee)
else
  args+=(background.color=0xfff78c6c)
fi


if [[ $NUMBERS != "" ]]; then
  args+=(drawing=on label="􀄯${FORMATTED_NUMBER_0} 􀄱${FORMATTED_NUMBER_1}")
else
  args=(drawing=off)
fi

sketchybar --set $NAME "${args[@]}"
