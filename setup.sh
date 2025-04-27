#!/bin/bash
set -e

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$script_dir"/common.sh

info "Starting setup in $script_dir."

# First step : identify the distro

for entry in "$script_dir"/*; do
   if [[ -d "$entry" ]] && [[ "$(basename "$entry")" != "post_install" ]]; then
       supported_distro_list+=("$(basename "$entry")")
   fi
done

distro=""
if [[ -f "/etc/os-release" ]]; then
    distro=$(source /etc/os-release && echo "$ID")
    distro_is_supported=false
    for supported_distro in "${supported_distro_list[@]}"; do
        if [[ "$supported_distro" == "$distro" ]]; then
            distro_is_supported=true
            break
        fi
    done
else
    error "/etc/os-release not found. Cannot determine distro."
    exit 1
fi

info "Found distro $distro."
if $distro_is_supported; then
    info "$distro is supported !"
else
    error "$distro is not supported. Supported distros are: ${supported_distro_list[*]}.
    Exiting..."
    exit 1
fi

# Second step : execute all distro-specific install scripts

# With special precautions to avoid executing anything weird or dangerous
# and to easily debug any permission problem/whatever annoyance can arise

execute_scripts_in_folder "$script_dir"/"$distro" || exit 1


# Third step : deploy the configuration using chezmoi (which has been installed before)

info "Deploying configuration..."
# This will copy the dotfiles to ~/.local/share/chezmoi
chezmoi init --apply git@github.com:GabrielCanaple/dotfiles.git

# Fourth step : distro-agnostic and post-install scripts

info "All packages installed, executing post-install scripts."
execute_scripts_in_folder "$script_dir"/post_install || exit 1
