#!/bin/bash

# This script automates virt-manager configs.
# It REQUIRES whitelisting these commands in the sudoers file!
# It uses absolute paths to mitigate against hidden env variables.

# ==========================================
# HELPER FUNCTIONS
# ==========================================

# Function to echo to terminal AND send a desktop notification
notify_status() {
    local message="$1"
    echo "$message"
    # Sends a standard notification. '-h string:x-dunst-stack-tag:vman' 
    # replaces the previous notification so they don't pile up on your screen.
    notify-send "Virt-Manager" "$message" -i virt-manager -h string:x-dunst-stack-tag:vman
}

# Function to execute a command, catch errors, and notify if it fails
execute_and_catch() {
    local action_name="$1"
    shift # Removes the first argument ($action_name) so we can execute the rest as a command
    
    # Run the command, redirect stderr (2) to stdout (1), and capture it in a variable
    local error_output
    error_output=$("$@" 2>&1 >/dev/null)
    local exit_code=$?

    # If the command failed (exit code is not 0)
    if [ $exit_code -ne 0 ]; then
        # Ignore the harmless "already active" network error
        if [[ "$error_output" == *"network is already active"* ]]; then
            return 0
        fi
        
        # Ignore the harmless "not active" network error during cleanup
        if [[ "$error_output" == *"network is not active"* ]]; then
            return 0
        fi

        # Print to terminal and send a critical notification for actual errors
        echo "ERROR ($action_name): $error_output"
        notify-send "Virt-Manager Error" "Failed to $action_name:\n$error_output" -u critical -i dialog-error
    fi
}

# ==========================================
# MAIN SCRIPT
# ==========================================

# Start required services
notify_status "Starting libvirt daemon..."
execute_and_catch "start libvirt daemon" sudo /usr/bin/systemctl start libvirtd

notify_status "Starting default network..."
execute_and_catch "start default network" sudo /usr/bin/virsh net-start default

notify_status "Launching virt-manager..."
# The script will pause on this line until you close the virt-manager window
GDK_DPI_SCALE=1.4 virt-manager

notify_status "virt-manager closed. Cleaning up..."

# Stop required services
echo "Stopping default network..."
execute_and_catch "stop default network" sudo /usr/bin/virsh net-destroy default

echo "Stopping libvirt daemon..."
execute_and_catch "stop libvirt daemon" sudo /usr/bin/systemctl stop libvirtd.service libvirtd.socket libvirtd-ro.socket libvirtd-admin.socket

notify_status "Virtualization services stopped."