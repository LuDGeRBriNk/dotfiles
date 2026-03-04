#!/usr/bin/env bash

# 1. Define your list of programs here. 
# Just add new names inside the parentheses separated by spaces.
PROGRAMS=("waybar" "hyprpaper" "hypridle")

# 2. Kill all programs in the list first
for prog in "${PROGRAMS[@]}"; do
    killall -q "$prog"
done

# Wait a fraction of a second to ensure ports and processes are fully released
sleep 0.2

# 3. Restart and verify each program individually
for prog in "${PROGRAMS[@]}"; do
    # Define a temporary log file for this specific program
    ERROR_LOG="/tmp/${prog}_error.log"
    
    # Start the program in the background. 
    # Standard output is hidden, but error output is saved to the log file.
    "$prog" > /dev/null 2> "$ERROR_LOG" &
    
    # Wait briefly to catch immediate crashes (e.g., bad config files)
    sleep 0.2
    
    # Check if the process is actually running using pgrep
    if pgrep -x "$prog" > /dev/null; then
        notify-send -u normal "UI Reset: Success" "$prog started successfully."
    else
        # If it crashed, grab the first 3 lines of the error log
        ERROR_MSG=$(head -n 3 "$ERROR_LOG")
        
        # Provide a fallback message if it crashed without leaving a log
        if [[ -z "$ERROR_MSG" ]]; then
            ERROR_MSG="Process crashed silently."
        fi
        
        # Send a critical notification with the exact error
        notify-send -u critical "UI Reset: $prog Failed" "$ERROR_MSG"
    fi
done
