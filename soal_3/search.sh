#!/bin/bash

# C D E
for region in genshin_character/*; do
    for img in "$region"/*; do
        fname=$(echo "$img" | awk -F '/' '{print $3}')
        char=$(echo "$fname" | awk -F ' -' '{print $2}')
        steghide extract -sf "$img" -p "" -xf "${char}.txt"

        decoded=$(cat "${char}.txt" | base64 -d)

        echo "$fname -> $(cat "${char}.txt")"
        if [[ "$decoded" == *http* ]]; then
            wget "$decoded"
            echo "$(date +"%Y/%m/%d %H:%M:%S") FOUND $img" >> image.log
            echo "$decoded" > "${char}.txt"
            exit 0
        else
            echo "$(date +"%Y/%m/%d %H:%M:%S") NOT FOUND $img" >> image.log
            rm "${char}.txt"
        fi
        sleep 1
    done
done
