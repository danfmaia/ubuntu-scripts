#!/bin/bash

# Read each line of autostart.config file
while read app; do
  # Ignore lines starting with #
  if [[ $app == \#* ]]; then
    continue
  fi

  # Start the application
  $app &
done < ~/scripts/autostart/autostart.config
