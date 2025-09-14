#!/bin/bash/

touch ~/.cache/pt_weather

weather=$(wget -qO- "https://api.weatherapi.com/v1/current.json?key=fa7f85cdc69d4c75884222250242110&q=Toronto,Canada" | jq -r '"\(.location.name) \(.current.temp_c)°C \(.current.condition.text)"')

echo $weather > ~/.cache/pt_weather
