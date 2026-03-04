#!/usr/bin/env python3
import json
import sys
import time
import urllib.parse
import urllib.request
import urllib.error
import html # Added to escape special characters

# SETTINGS
CITY_DEFAULT = "Bauru"
RETRY_INTERVAL = 10     # Seconds to wait after failure
SUCCESS_INTERVAL = 3600 # Seconds to wait after success (1 Hour)

def get_weather_data(city_name):
    city_encoded = urllib.parse.quote(city_name)
    url = f"https://wttr.in/{city_encoded}?format=j1"

    # Set a timeout so the script doesn't hang forever
    with urllib.request.urlopen(url, timeout=5) as response:
        return json.loads(response.read().decode())

def parse_weather(data, city_name):
    current = data['current_condition'][0]
    temp_c = current['temp_C']
    desc = current['weatherDesc'][0]['value']
    
    icon = " " # Cloud
    desc_lower = desc.lower()
    if "sun" in desc_lower or "clear" in desc_lower:
        icon = " "
    elif "rain" in desc_lower or "shower" in desc_lower:
        icon = " "
    elif "thunder" in desc_lower:
        icon = " "
    elif "snow" in desc_lower:
        icon = " "
    elif "fog" in desc_lower or "mist" in desc_lower:
        icon = " "
    
    city_cap = city_name.capitalize()
    text = f"{icon}{temp_c}°C {city_cap}"
    
    tooltip = (f"<b>{desc}</b>\n"
               f"Feels like: {current['FeelsLikeC']}°C\n"
               f"Humidity: {current['humidity']}%\n"
               f"Wind: {current['windspeedKmph']} km/h")

    return {"text": text, "tooltip": tooltip, "class": "weather"}

def main():
    if len(sys.argv) > 1:
        city = sys.argv[1]
    else:
        city = CITY_DEFAULT

    while True:
        try:
            data = get_weather_data(city)
            output = parse_weather(data, city)
            print(json.dumps(output))
            sys.stdout.flush() 
            time.sleep(SUCCESS_INTERVAL)

        except Exception as e:
            # SANITIZE ERROR MESSAGE
            # 1. Convert exception to string
            error_msg = str(e)
            # 2. Escape HTML characters (<, >, &, etc.) so Waybar doesn't crash
            safe_error = html.escape(error_msg)
            
            error_output = {
                "text": " Retrying...", 
                "tooltip": f"Connection lost. Retrying in {RETRY_INTERVAL}s.\nError: {safe_error}", 
                "class": "disconnected"
            }
            print(json.dumps(error_output))
            sys.stdout.flush()
            time.sleep(RETRY_INTERVAL)

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        sys.exit(0)