#!/bin/bash

echo "Updating Cursor to version 0.48.6..."

# Force kill Cursor processes more specifically
echo "Forcefully closing all Cursor processes..."

# Kill by process name (the actual binary) but not this script
for pid in $(pgrep -x cursor); do
    kill -9 $pid 2>/dev/null || true
done

# Kill processes running from the mount point
pkill -9 -f "/tmp/.mount_cursor" || true

sleep 2

# Double-check if Cursor is still running (excluding this script)
cursor_still_running=false
for pid in $(pgrep -x cursor); do
    # Skip this script's process
    if [ "$pid" != "$$" ] && [ "$pid" != "$PPID" ]; then
        cursor_still_running=true
        break
    fi
done

if $cursor_still_running || pgrep -f "/tmp/.mount_cursor" > /dev/null; then
    echo "Warning: Some Cursor processes are still running. Attempting to force kill again..."
    
    for pid in $(pgrep -x cursor); do
        if [ "$pid" != "$$" ] && [ "$pid" != "$PPID" ]; then
            kill -9 $pid 2>/dev/null || true
        fi
    done
    
    pkill -9 -f "/tmp/.mount_cursor" || true
    sleep 2
    
    # Final check
    cursor_still_running=false
    for pid in $(pgrep -x cursor); do
        if [ "$pid" != "$$" ] && [ "$pid" != "$PPID" ]; then
            cursor_still_running=true
            break
        fi
    done
    
    if $cursor_still_running || pgrep -f "/tmp/.mount_cursor" > /dev/null; then
        echo "Error: Unable to kill all Cursor processes. Please try closing Cursor manually or reboot your system."
        exit 1
    fi
fi

# Backup the current cursor binary
echo "Backing up current cursor binary..."
sudo cp /usr/local/bin/cursor /usr/local/bin/cursor.bak

# Replace with the new AppImage
echo "Installing new Cursor version..."
sudo cp ~/Downloads/Cursor-0.48.6-x86_64.AppImage /usr/local/bin/cursor
sudo chmod +x /usr/local/bin/cursor

echo "Cursor has been updated to version 0.48.6!"
echo "You can now start Cursor again."
