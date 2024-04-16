#!/usr/bin/env bash

export GREEN_COLOR="32"
export YELLOW_COLOR="33"
export RED_COLOR="31"

echo_with_color() {
    local color_code="$1"
    local message="$2"
    echo -e "\n\033[${color_code}m$message\033[0m\n"
}

get_package_list() {
    local package_list_name="$1"
    local gist_url="https://gist.githubusercontent.com/timmyb824/807597f33b14eceeb26e4e6f81d45962/raw/${package_list_name}"

    # Fetch the package list, remove comments, and trim whitespace
    curl -fsSL "$gist_url" | sed 's/#.*//' | awk '{$1=$1};1'
}

# Function to install a package with basher
load_package_into_env() {
    local package=$1
    if env +"$package"; then
        echo_with_color "$GREEN_COLOR" "${package} loaded successfully"
    else
        echo_with_color "$YELLOW_COLOR" "Failed to load ${package}"
    fi
}

# Get the list of packages from the gist
package_list=$(get_package_list pkgx_linux_env.list)

for cmd in curl sed awk env; do
    command -v "$cmd" >/dev/null 2>&1 || { echo_with_color "$RED_COLOR" >&2 "I require $cmd but it's not installed. Aborting."; exit 1; }
done

# Check if the package list is retrieved successfully
if [ -z "$package_list" ]; then
    echo_with_color "$RED_COLOR" "Failed to retrieve the package list."
    exit 1
fi

while IFS= read -r package; do
    if [ -n "$package" ]; then # Ensure the line is not empty
        load_package_into_env "$package"
    fi
done <<<"$package_list"
