#!/bin/bash
source "$(dirname "$0")/../common.sh"

# rclone service settings
mount_point="$HOME/OneDrive"
remote_name="OneDrive:"
service_dest="$HOME"/.config/systemd/user/rclone-mount.service

info "Setting up remote $remote_name with rclone in $mount_point."

mkdir -p "$mount_point"
mkdir -p "$(dirname "$service_dest")"

tmp_file="$(mktemp)"

sed \
    -e "s|%REMOTE_NAME%|$remote_name|g" \
    -e "s|%MOUNT_POINT%|$mount_point|g" \
    "$(dirname "$0")/rclone-mount.service.template" >"$tmp_file"

if [[ ! -f "$service_dest" ]] || ! cmp -s "$tmp_file" "$service_dest"; then
    # This is necessary to allow FUSE mounts to be made available to other users
    add_line_to_file_if_not_exists_root "/etc/fuse.conf" "user_allow_other"

    # Prompt the user to add the remote
    info "Follow the instructions and add remote $remote_name. Quit if already present."
    rclone config reconnect "$remote_name"

    mv "$tmp_file" "$service_dest"
    systemctl --user daemon-reload
    systemctl --user enable --now "rclone-mount.service"

    info "Successfully configured and mounted $remote_name with rclone."
else
    info "$remote_name already configured with rclone."
    rm "$tmp_file"
fi
