#!/bin/bash

# A
wget -O genshin.zip "https://drive.google.com/uc?export=download&id=1oGHdTf4_76_RacfmQIV4i7os4sGwa9vN"
unzip genshin.zip

unzip genshin_character.zip

for encoded_file in genshin_character/*; do
    encoded_base=$(basename "$encoded_file")
    decoded_name=$(echo -n "$encoded_base" | xxd -r -p)
    mv "$encoded_file" "genshin_character/${decoded_name}.jpg"

    decoded_base=$(basename "$decoded_name")
    info=$(grep "$decoded_base" list_character.csv)

    name=$(echo "$info" | awk -F ',' '{print $1}')
    region=$(echo "$info" | awk -F ',' '{print $2}')
    element=$(echo "$info" | awk -F ',' '{print $3}')
    weapon=$(echo "$info" | awk -F ',' '{print $4}')

    mkdir -p "genshin_character/${region}"

    new_name="${region} - ${name} - ${element} - ${weapon}"
    clean_name=$(echo "$new_name" | tr -d '\015')
    mv "genshin_character/${decoded_name}.jpg" "genshin_character/${region}/${clean_name}.jpg"
done


# B
for weapon in Catalyst Sword Claymore Bow Polearm; do
    count=$(find genshin_character/ -name "*$weapon.jpg" | wc -l)
    echo "$weapon: $count"
done

rm genshin.zip
rm genshin_character.zip
rm list_character.csv