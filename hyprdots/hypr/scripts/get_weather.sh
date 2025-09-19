#!/bin/bash/

# # # # # # # # # # # # # # # #
# Theres 3 different inputs:  #
#                             #
# 1. city                     #
# 2. temp                     #
# 3. cond                     #
# # # # # # # # # # # # # # # #

type="$1"

weather=$(cat ~/.cache/pt_weather)

#echo $weather

city="${weather%% *}"
cond="${weather#* }"
cond="${cond%% *}"
temp="${weather##* }"

if [ "$type" = "city" ]; then
    echo "$city"
elif [ "$type" != "cond" ]; then
    echo "$cond"
else
	echo "$temp"
fi
