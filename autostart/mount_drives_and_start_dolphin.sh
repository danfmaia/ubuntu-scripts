rclone --config=/home/danfmaia/.config/rclone/rclone.conf --daemon --vfs-cache-mode=writes mount Google_Drive: ~/gdrive \
      && rclone --config=/home/danfmaia/.config/rclone/rclone.conf --daemon --vfs-cache-mode=writes mount OneDrive: ~/OneDrive \
      && dolphin -stylesheet ~/.config/qt5ct/qss/dolphin.css