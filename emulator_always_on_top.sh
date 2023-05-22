#!/bin/bash

# get the window ID of the target window
WINDOW_ID=$(wmctrl -l | grep "Android Emulator - " | awk '{print $1}')

# check if the window ID is empty
if [[ -z "$WINDOW_ID" ]]; then
  echo "Emulator window not found. Exiting."
  exit 1
fi

# define the code to execute when the window is maximized
function on_maximize() {
  wmctrl -i -r $(wmctrl -l | grep ' Android Emulator - ' | sed -e 's/\s.*$//g') -b add,above
  wmctrl -i -r $(wmctrl -l | grep ' Emulator$' | sed -e 's/\s.*$//g') -b add,above
}

# define the code to execute when the window is minimized
function on_minimize() {
  wmctrl -i -r $(wmctrl -l | grep ' Android Emulator - ' | sed -e 's/\s.*$//g') -b remove,above
  wmctrl -i -r $(wmctrl -l | grep ' Emulator$' | sed -e 's/\s.*$//g') -b remove,above
}

# set initial window state to "unknown"
WINDOW_STATE="unknown"

# loop forever and check for window events
while true; do
  # check if the window still exists
  wmctrl -l | grep -q "$WINDOW_ID"
  WINDOW_EXISTS=$?

  if [[ $WINDOW_EXISTS -ne 0 ]]; then
    echo "Emulator window closed. Exiting."
    exit 0
  fi

  # wait for the window to be maximized or minimized
  geometry_output=$(xdotool getwindowgeometry $WINDOW_ID 2>&1)

  # check if the window was maximized or minimized
  if [[ "$(xprop -id $WINDOW_ID _NET_WM_STATE | grep '_NET_WM_STATE_HIDDEN')" != "" ]]; then
    if [[ "$WINDOW_STATE" != "minimized" ]]; then
      WINDOW_STATE="minimized"
      on_minimize
    fi
  else
    if [[ "$WINDOW_STATE" != "maximized" ]]; then
      WINDOW_STATE="maximized"
      on_maximize
    fi
  fi

  # discard the output of the xdotool command
  echo "$geometry_output" > /dev/null
done
