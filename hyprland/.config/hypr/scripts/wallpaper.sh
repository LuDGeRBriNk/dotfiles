#!/bin/bash

# ==========================================================
# CONFIGURATION & ARGUMENTS
# ==========================================================
WALLPAPER_DIR="$HOME/vaults/vault/Media/Images/Wallpapers"
STATE_FILE="$HOME/.cache/current_wallpaper.txt"

ACTION="${1:-random}" 

if [[ "$ACTION" != "random" && "$ACTION" != "next" && "$ACTION" != "prev" && "$ACTION" != "previous" ]]; then
    echo "Usage: $0 [random|next|prev]"
    exit 1
fi

# ==========================================================
# 1. GET ALL WALLPAPERS
# ==========================================================
mapfile -d '' WALLPAPERS < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" -o -iname "*.webp" \) -print0 | sort -z)
TOTAL_WPS=${#WALLPAPERS[@]}

if [ "$TOTAL_WPS" -eq 0 ]; then
    echo "Error: No wallpapers found in $WALLPAPER_DIR"
    exit 1
fi

# ==========================================================
# 2. READ STATE AND CALCULATE TARGET
# ==========================================================
if [[ "$ACTION" == "random" ]]; then
    TARGET_INDEX=$(( RANDOM % TOTAL_WPS ))
else
    CURRENT_WP=""
    if [ -f "$STATE_FILE" ]; then
        CURRENT_WP=$(cat "$STATE_FILE")
    fi
    
    CURRENT_WP_NAME=$(basename "$CURRENT_WP")
    CURRENT_INDEX=-1

    # Compare basenames
    for i in "${!WALLPAPERS[@]}"; do
        if [[ "$(basename "${WALLPAPERS[$i]}")" == "$CURRENT_WP_NAME" ]]; then
            CURRENT_INDEX=$i
            break
        fi
    done

    if [[ "$ACTION" == "next" ]]; then
        TARGET_INDEX=$(( (CURRENT_INDEX + 1) % TOTAL_WPS ))
    else
        if [ "$CURRENT_INDEX" -eq -1 ]; then
            TARGET_INDEX=$(( TOTAL_WPS - 1 )) 
        else
            TARGET_INDEX=$(( (CURRENT_INDEX - 1 + TOTAL_WPS) % TOTAL_WPS ))
        fi
    fi
fi

TARGET_FILE="${WALLPAPERS[$TARGET_INDEX]}"

# ==========================================================
# 3. HYPRPAPER HOUSEKEEPING
# ==========================================================
# Specifically unload only the old wallpaper to avoid the "Unknown request" error
if [ -f "$STATE_FILE" ]; then
    OLD_WP=$(cat "$STATE_FILE")
    hyprctl hyprpaper unload "$OLD_WP" >/dev/null 2>&1
fi

# Preload the new one
hyprctl hyprpaper preload "$TARGET_FILE"

# ==========================================================
# 4. APPLY TO ALL MONITORS
# ==========================================================
MONITORS=$(hyprctl monitors | grep "Monitor" | awk '{print $2}')

for MON in $MONITORS; do
    hyprctl hyprpaper wallpaper "$MON,$TARGET_FILE"
done

# ==========================================================
# 5. SAVE STATE & NOTIFY
# ==========================================================
# Write the newly applied wallpaper to the state file
echo "$TARGET_FILE" > "$STATE_FILE"

# Define the success message
WP_NAME=$(basename "$TARGET_FILE")

# Keep terminal output for debugging
echo "Done! Applied $WP_NAME to all monitors."

# Send desktop notification (vanishes after 5000ms)
notify-send -t 5000 "Wallpaper Changed" "Applied $WP_NAME"