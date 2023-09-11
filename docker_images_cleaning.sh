#!/bin/bash

# Get the current date
current_date=$(date +%s)

# Number of days to consider images as unused
days_threshold=3

# Get a list of unused images and their creation times
unused_images=$(docker images -q --filter "dangling=true" --filter "before=$(date -d @$((current_date - 86400 * days_threshold)) +%Y-%m-%dT%H:%M:%S.%N%z)")
# 86400 seconds = 1 day

# Iterate through the list of unused images
for image_id in $unused_images; do
    # Check if this image is being used in a container or service
    is_used=$(docker ps -a --format "{{.Image}}" | grep -c "$image_id")
    
    if [ $is_used -eq 0 ]; then
        # Remove the image if it's not in use
        echo "Removing image $image_id"
        docker rmi $image_id
    else
        echo "Not removing image $image_id because it is in use"
    fi
done
