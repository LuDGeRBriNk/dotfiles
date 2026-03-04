#!/bin/bash

# Define a temporary file to store the state (temp vs usage)
STATE_FILE="/tmp/gpu_module_state"

# -----------------------------------------------------------------------------
# TOGGLE LOGIC
# -----------------------------------------------------------------------------
# If the script is called with the --toggle argument, switch the state
if [[ "$1" == "--toggle" ]]; then
    if [[ -f "$STATE_FILE" ]]; then
        CURRENT_STATE=$(cat "$STATE_FILE")
        if [[ "$CURRENT_STATE" == "temp" ]]; then
            echo "usage" > "$STATE_FILE"
        else
            echo "temp" > "$STATE_FILE"
        fi
    else
        # Default to usage on first click if file doesn't exist yet 
        # (since default visual state is now temp)
        echo "usage" > "$STATE_FILE"
    fi
    exit 0
fi

# -----------------------------------------------------------------------------
# DATA RETRIEVAL
# -----------------------------------------------------------------------------
# Check if nvidia-smi is installed
if ! command -v nvidia-smi &> /dev/null; then
    echo '{"text": "N/A", "tooltip": "nvidia-smi missing", "class": "excellent"}'
    exit
fi

# Fetch Usage and Temperature simultaneously (more efficient)
# Returns: usage_percent, temperature_celsius
data=$(nvidia-smi --query-gpu=utilization.gpu,temperature.gpu --format=csv,noheader,nounits)

# Parse the comma-separated output into variables
usage=$(echo "$data" | awk -F', ' '{print $1}')
temp=$(echo "$data" | awk -F', ' '{print $2}')

# Fallback validation: If variables are empty/invalid, set defaults
if [[ -z "$usage" || ! "$usage" =~ ^[0-9]+$ ]]; then usage=0; fi
if [[ -z "$temp" || ! "$temp" =~ ^[0-9]+$ ]]; then temp=0; fi

# -----------------------------------------------------------------------------
# DISPLAY LOGIC
# -----------------------------------------------------------------------------
# Read the current state (default to 'temp' if file doesn't exist)
if [[ -f "$STATE_FILE" ]]; then
    mode=$(cat "$STATE_FILE")
else
    mode="temp"
fi

# Prepare the output variables based on the mode
if [[ "$mode" == "temp" ]]; then
    # MODE: TEMPERATURE
    # Main text shows °C, Tooltip shows Usage
    display_text="${temp}°C"
    tooltip_text="GPU Usage: ${usage}%"
else
    # MODE: USAGE
    # Main text shows %, Tooltip shows Temp
    display_text="${usage}%"
    tooltip_text="Temperature: ${temp}°C"
fi

# -----------------------------------------------------------------------------
# CLASS LOGIC (Keeping your original thresholds)
# -----------------------------------------------------------------------------
if (( temp >= 87 )); then
    class="critical"

elif (( temp >= 85 )); then
    class="bad"

elif (( temp >= 75 )); then
    class="warning"

elif (( temp >= 65 )); then
    class="medium"

elif (( temp >= 61 )); then
    class="good"

else
    class="excellent"
fi

# -----------------------------------------------------------------------------
# JSON OUTPUT
# -----------------------------------------------------------------------------
echo "{\"text\": \"$display_text\", \"tooltip\": \"$tooltip_text\", \"percentage\": $usage, \"class\": \"$class\"}"