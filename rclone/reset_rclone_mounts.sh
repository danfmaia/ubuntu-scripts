#!/bin/bash

# Terminate any running rclone processes
echo "Terminating any running rclone processes..."
sudo pkill -f rclone

# Unmount existing mount points
echo "Unmounting existing mount points..."
sudo umount -l /home/danfmaia/gdrive
sudo umount -l /home/danfmaia/OneDrive

# Remove and recreate the mount directories
echo "Removing and recreating mount directories..."
sudo rm -rf /home/danfmaia/gdrive /home/danfmaia/OneDrive
mkdir -p /home/danfmaia/gdrive /home/danfmaia/OneDrive
sudo chown danfmaia:danfmaia /home/danfmaia/gdrive /home/danfmaia/OneDrive
sudo chmod 755 /home/danfmaia/gdrive /home/danfmaia/OneDrive

# Restart the rclone service
echo "Restarting rclone service..."
sudo systemctl restart rclone.service

# Verify if mounts are successful
echo "Verifying mount status..."
if ls /home/danfmaia/gdrive &>/dev/null && ls /home/danfmaia/OneDrive &>/dev/null; then
    echo "Mounts are successfully reset and active."
else
    echo "Failed to mount one or both directories. Check rclone service and logs for details."
fi
