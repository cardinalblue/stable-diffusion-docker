#!/bin/bash

# folder="/instruments_downloaded/lora/"
# mkdir -p "$folder"
# inotifywait -m -e create --format '%w%f' $folder | while read -r newfile; 
# do
#   echo "New item detected: $newfile"
#   if [ -f "$newfile" ]; then
#     echo "New file detected: $newfile"
#     cp "$newfile" /workspace/stable-diffusion-webui/models/Lora/
#   fi
# done &

# folder="/instruments_downloaded/stable-diffusion/"
# mkdir -p "$folder"
# inotifywait -m -e create -e move --format '%w%f' "$folder" | while read newfile
# do
#   echo "New file detected: $newfile"
#   cp $newfile /workspace/stable-diffusion-webui/models/Stable-diffusion/
# done &

folder="/workspace/stable-diffusion-webui/log/images/"
mkdir -p "$folder"
inotifywait -m -e create,move,ISDIR --format '%w%f' "$folder" | while read newfile
do
  echo "New folder detected: $newfile"
  python /create-composition.py ${newfile}.json
done &

wait