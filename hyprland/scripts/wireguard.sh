#!/bin/bash

# This script toggles the WireGuard VPN connection and fetches the external IP.
# It REQUIRES whitelisting these commands in the sudoers file!

# ==========================================
# HELPER FUNCTIONS
# ==========================================

notify_status() {
    local message="$1"
    local icon="${2:-network-vpn}"
    
    notify-send "WireGuard VPN" "$message" \
        -i "$icon" \
        -h string:x-dunst-stack-tag:wgvpn \
        -h int:transient:1 \
        -t 4000
}

execute_and_catch() {
    local action_name="$1"
    shift 
    
    local error_output
    error_output=$("$@" 2>&1 >/dev/null)
    local exit_code=$?

    if [ $exit_code -ne 0 ]; then
        notify-send "VPN Error" "Failed to $action_name:\n$error_output" -u critical -i dialog-error
        exit 1
    fi
}

get_ip() {
    # Fetch the external IP with a 5-second timeout to prevent script hangs
    local ip
    ip=$(curl -s --max-time 5 ifconfig.me)
    
    # Fallback just in case the ping fails
    if [ -z "$ip" ]; then
        echo "Unknown (Network Timeout)"
    else
        echo "$ip"
    fi
}

# ==========================================
# MAIN SCRIPT (TOGGLE LOGIC)
# ==========================================

if systemctl is-active --quiet wg-quick@wg0; then
    
    # VPN is ON -> Turn it OFF
    notify_status "Disconnecting wg0..." "network-offline"
    execute_and_catch "stop wg-quick@wg0" sudo /usr/bin/systemctl stop wg-quick@wg0
    
    # Wait for the normal routing table to restore
    sleep 1.5
    CURRENT_IP=$(get_ip)
    
    notify_status "VPN Disconnected.\nExternal IP: $CURRENT_IP" "network-offline"

else

    # VPN is OFF -> Turn it ON
    notify_status "Connecting wg0..." "network-vpn"
    execute_and_catch "start wg-quick@wg0" sudo /usr/bin/systemctl start wg-quick@wg0
    
    # Wait for the WireGuard handshake and routing to establish
    sleep 2
    CURRENT_IP=$(get_ip)
    
    notify_status "VPN Connected.\nExternal IP: $CURRENT_IP" "network-vpn"

fi