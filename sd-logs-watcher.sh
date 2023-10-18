#!/bin/bash

folder="/workspace/logs/parameters"
mkdir -p "$folder"
tail -f /workspace/logs/webui.log | while read -r line; do
    timestamp=$(echo "$line" | jq -r '.job_timestamp')
    seed=$(echo "$line" | jq -r '.seed')
    if [[ ! -z "$timestamp" ]]; then  # Check if timestamp is not empty
        filename="${timestamp}-${seed}.json"
        echo "$line" >> "${folder}/${filename}"
    fi
done
