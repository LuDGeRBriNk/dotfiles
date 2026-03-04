#!/bin/bash

# Improved Fireworks Display Script

# Function to generate a random position
random_position() {
  local rows=$(tput lines)
  local cols=$(tput cols)
  local row=$((RANDOM % (rows - 5) + 3)) # Avoid edges
  local col=$((RANDOM % (cols - 10) + 5))
  echo "$row" "$col"
}

# Function to draw an explosion at a position
draw_explosion() {
  local row=$1
  local col=$2
  local frames=("."
                " . "
                " .o. "
                " .oO. "
                " oOOOo ")
  
  for frame in "${frames[@]}"; do
    clear
    echo -ne "\033[${row};${col}H\033[1;3$((RANDOM % 8 + 1))m${frame}\033[0m"
    sleep 0.1
  done
}

# Clear screen and hide cursor
clear
tput civis

# Trap to restore the terminal on exit
trap 'tput cnorm; clear' EXIT

# Run multiple fireworks
for i in {1..10}; do
  read row col < <(random_position)
  draw_explosion "$row" "$col"
done

# Restore cursor and clear screen
tput cnorm
clear
echo -e "\033[0mThanks for watching! 🎆"

