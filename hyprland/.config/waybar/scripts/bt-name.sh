#!/bin/bash

# 1. Get the MAC address of the first connected device
# We use 'cut' to handle the format: "Device AA:BB:CC:DD:EE:FF Name"
MAC=$(bluetoothctl devices Connected | head -n1 | cut -d ' ' -f 2)

# 2. If no MAC is found, we are disconnected
if [ -z "$MAC" ]; then
    echo "Bluetooth"
    exit 0
fi

# 3. Get the info for that MAC
# We look for "Alias" instead of "Name" because it's more reliable (it falls back to the Name if no custom Alias is set)
INFO=$(bluetoothctl info "$MAC")
NAME=$(echo "$INFO" | grep "Alias" | cut -d ' ' -f 2-)
BATTERY=$(echo "$INFO" | grep "Battery Percentage" | awk -F '[()]' '{print $2}')

# 4. formatting
if [ -z "$BATTERY" ]; then
    echo "$NAME"
else
    echo "$NAME $BATTERY%"
fi