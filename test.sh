while true; do
    POWER_SOURCE=$(pmset -g batt | grep 'Now drawing from' | awk '{print $4}')
    if [[ "$POWER_SOURCE" == "AC" ]]; then
        CONNECTED=true
    elif [[ "$POWER_SOURCE" == "Battery" && "$CONNECTED" == "true" ]]; then
        # Replace with your desired action, e.g., triggering a shortcut
    osascript -e 'tell application "Shortcuts Events" to run shortcut "Laptop Alarm"'
        CONNECTED=false
        fi
    sleep 5
done