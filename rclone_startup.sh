#!/bin/bash

# Wait for the network to come up
sleep 10

# Start the rclone mount command
/usr/bin/rclone --config=/home/danfmaia/.config/rclone/rclone.conf \
        mount Google_Drive: /home/danfmaia/gdrive \
        --daemon \
        --vfs-cache-mode=writes
