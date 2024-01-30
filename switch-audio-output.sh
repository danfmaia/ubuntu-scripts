#!/bin/bash

current_sink=$(pacmd list-sinks | awk '$1 == "*" && $2 == "index:" {print $3}')
sinks=($(pacmd list-sinks | awk '/index:/{print $NF}'))

# Find the index of the current sink in the array
for i in "${!sinks[@]}"; do
  if [[ ${sinks[i]} = "${current_sink}" ]]; then
    current_sink_index=$i
    break
  fi
done

# Calculate the index of the next sink in the cycle
next_sink_index=$(( (current_sink_index + 1) % ${#sinks[@]} ))

# Get the index of the next sink
next_sink=${sinks[$next_sink_index]}

# Switch to the next sink
pacmd set-default-sink ${next_sink}

# Unload and reload the PulseAudio module responsible for routing audio to the default sink
pactl unload-module module-udev-detect && pactl load-module module-udev-detect
