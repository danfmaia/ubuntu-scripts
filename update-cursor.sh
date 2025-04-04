#!/bin/bash

# Check if AppImage path is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <path_to_cursor_appimage>"
    echo "Example: $0 ~/Downloads/Cursor-NEW_VERSION-x86_64.AppImage"
    exit 1
fi

NEW_APPIMAGE_PATH="$1"
FILENAME=$(basename "$NEW_APPIMAGE_PATH")

# Check if the provided file exists
if [ ! -f "$NEW_APPIMAGE_PATH" ]; then
    echo "Error: AppImage file not found at '$NEW_APPIMAGE_PATH'"
    exit 1
fi

echo "Attempting to update Cursor using $FILENAME..."

# Force kill Cursor processes more specifically
echo "Forcefully closing all Cursor processes..."

# Kill by process name (the actual binary) but not this script
for pid in $(pgrep -x cursor); do
    # Skip this script's process if running with bash/sh explicitly
    if [ "$pid" != "$$" ] && [ "$pid" != "$PPID" ] && [ "$(ps -p $pid -o comm=)" != "bash" ] && [ "$(ps -p $pid -o comm=)" != "sh" ]; then
         # Check if parent is also not this script (covers cases like sudo)
         parent_pid=$(ps -o ppid= -p $pid)
         if [ "$parent_pid" != "$$" ] && [ "$parent_pid" != "$PPID" ]; then
             echo "Killing cursor process PID: $pid"
             kill -9 $pid 2>/dev/null || true
         fi
    fi
done

# Kill processes running from the mount point more reliably
pkill -9 -f "/tmp/\.mount_cursor.*${USER:-$(id -un)}" || true

sleep 2

# Double-check if Cursor is still running (excluding this script and related processes)
cursor_still_running=false
for pid in $(pgrep -x cursor); do
    # Skip this script's process and parents
    if [ "$pid" != "$$" ] && [ "$pid" != "$PPID" ] && [ "$(ps -p $pid -o comm=)" != "bash" ] && [ "$(ps -p $pid -o comm=)" != "sh" ]; then
         parent_pid=$(ps -o ppid= -p $pid)
         if [ "$parent_pid" != "$$" ] && [ "$parent_pid" != "$PPID" ]; then
             # Check command path isn't the script itself if run directly
             cmd_path=$(readlink -f /proc/$pid/exe || echo "")
             script_path=$(readlink -f "$0" || echo "")
             if [ "$cmd_path" != "$script_path" ]; then
                cursor_still_running=true
                echo "Detected potentially running cursor process (PID: $pid, Command: $(ps -p $pid -o comm=))"
                break
             fi
         fi
    fi
done

# Also check mount point processes again
if pgrep -f "/tmp/\.mount_cursor.*${USER:-$(id -un)}" > /dev/null; then
    echo "Detected potentially running cursor mount process."
    cursor_still_running=true
fi

if $cursor_still_running; then
    echo "Warning: Some Cursor processes might still be running. Attempting to force kill again..."

    for pid in $(pgrep -x cursor); do
         if [ "$pid" != "$$" ] && [ "$pid" != "$PPID" ] && [ "$(ps -p $pid -o comm=)" != "bash" ] && [ "$(ps -p $pid -o comm=)" != "sh" ]; then
             parent_pid=$(ps -o ppid= -p $pid)
             if [ "$parent_pid" != "$$" ] && [ "$parent_pid" != "$PPID" ]; then
                 echo "Force killing cursor process PID: $pid"
                 kill -9 $pid 2>/dev/null || true
             fi
         fi
    done

    pkill -9 -f "/tmp/\.mount_cursor.*${USER:-$(id -un)}" || true
    sleep 2

    # Final check
    final_check_failed=false
    for pid in $(pgrep -x cursor); do
        if [ "$pid" != "$$" ] && [ "$pid" != "$PPID" ] && [ "$(ps -p $pid -o comm=)" != "bash" ] && [ "$(ps -p $pid -o comm=)" != "sh" ]; then
             parent_pid=$(ps -o ppid= -p $pid)
             if [ "$parent_pid" != "$$" ] && [ "$parent_pid" != "$PPID" ]; then
                 cmd_path=$(readlink -f /proc/$pid/exe || echo "")
                 script_path=$(readlink -f "$0" || echo "")
                 if [ "$cmd_path" != "$script_path" ]; then
                     echo "Error: Still detected running cursor process (PID: $pid)"
                     final_check_failed=true
                     break
                 fi
             fi
        fi
    done

    if ! $final_check_failed && pgrep -f "/tmp/\.mount_cursor.*${USER:-$(id -un)}" > /dev/null; then
         echo "Error: Still detected running cursor mount process."
         final_check_failed=true
    fi

    if $final_check_failed; then
        echo "Error: Unable to kill all Cursor processes. Please try closing Cursor manually or reboot your system."
        exit 1
    fi
fi

# Backup the current cursor binary
echo "Backing up current cursor binary to /usr/local/bin/cursor.bak..."
sudo cp /usr/local/bin/cursor /usr/local/bin/cursor.bak

# Replace with the new AppImage
echo "Installing new Cursor version from $NEW_APPIMAGE_PATH..."
sudo cp "$NEW_APPIMAGE_PATH" /usr/local/bin/cursor
sudo chmod +x /usr/local/bin/cursor

echo "Cursor has been updated using $FILENAME!"
echo "You can now start Cursor again."
