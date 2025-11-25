#!/usr/bin/env bash
set -euo pipefail

read -rp "Enter directory: " DIR
[[ -d "$DIR" ]] || { echo "Not a directory bro."; exit 1; }

read -rp "Word to replace in filenames: " OLD
read -rp "Replace with: " NEW

echo "Renaming files inside: $DIR"

(
    RENAME_COUNT=0
    while true; do
        # collect files matching OLD
        mapfile -d '' FILES < <(find "$DIR" -maxdepth 1 -type f -name "*$OLD*" -print0)
        [[ ${#FILES[@]} -gt 0 ]] || break

        for file in "${FILES[@]}"; do
            name=$(basename "$file")
            newname="${name//$OLD/$NEW}"
            newpath="$DIR/$newname"

            # avoid overwrite
            if [[ -e "$newpath" ]]; then
                idx=1
                while [[ -e "${newpath}_$idx" ]]; do ((idx++)); done
                newpath="${newpath}_$idx"
            fi

            mv "$file" "$newpath"
            ((RENAME_COUNT++))
        done
    done

    echo "$RENAME_COUNT" > /tmp/.rename_count_"$$"
) &
TASK_PID=$!

# spinner
while kill -0 "$TASK_PID" 2>/dev/null; do
    for var in / - \\ \|; do
        echo -en "\r$var"
        sleep 0.1
    done
done

wait "$TASK_PID"
COUNT=$(cat /tmp/.rename_count_"$$")
rm -f /tmp/.rename_count_"$$"

echo -e "\rDone! Renamed $COUNT file(s).      "

