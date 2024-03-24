#!/bin/bash

# A
wget -O genshin.zip "https://drive.google.com/uc?export=download&id=1oGHdTf4_76_RacfmQIV4i7os4sGwa9vN"
unzip genshin.zip

unzip genshin_character.zip

for encoded_filename in genshin_character/*; do
    encoded_basename=$(basename "$encoded_filename")
    decoded_filename=$(echo -n "$encoded_basename" | xxd -r -p)
    mv "$encoded_filename" "genshin_character/${decoded_filename}.jpg"

    decoded_basename=$(basename "$decoded_filename")
    character_info=$(grep "$decoded_basename" list_character.csv)

    if [ -n "$character_info" ]; then
        character_name=$(echo "$character_info" | cut -d ',' -f 1)
        character_region=$(echo "$character_info" | cut -d ',' -f 2)
        character_element=$(echo "$character_info" | cut -d ',' -f 3)
        character_weapon=$(echo "$character_info" | cut -d ',' -f 4)
    fi

    mkdir -p "genshin_character/${character_region}"

    new_filename="${character_region} - ${character_name} - ${character_element} - ${character_weapon}"
    clean_filename=$(echo "$new_filename" | tr -d '\015')
    mv "genshin_character/${decoded_filename}.jpg" "genshin_character/${character_region}/${clean_filename}.jpg"
done

# B
for weapon in Catalyst Sword Claymore Bow Polearm; do
    count=$(find genshin_character/ -name "*$weapon.jpg" | wc -l)
    echo "$weapon: $count"
done

rm genshin.zip
rm genshin_character.zip
rm list_character.csv