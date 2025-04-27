#!/bin/bash

source "$(dirname "$0")/../common.sh"

sudo pacman -S --noconfirm --needed $(cat "$(dirname "$0")"/package_list.txt)

# This is an AUR package, always ask for user confirmation
warning "About to install AUR packages. Proceed? (y/n): "
if ! prompt_yes_no; then
    info "Skipping AUR packages"
    exit 0
fi

yay -S brave-bin
