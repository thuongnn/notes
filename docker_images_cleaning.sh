#!/bin/bash

# Get the current date in UTC
current_date=$(date -u +%s)

# Number of days to consider images as unused
days_threshold=3

# Calculate the cutoff date in UTC
cutoff_date=$(date -u -d "@$((current_date - 86400 * days_threshold))" +%Y-%m-%dT%H:%M:%S.%N%z)

# Get a list of unused images and their creation times
unused_images=$(docker images -q --filter "dangling=true")
# 86400 seconds = 1 day

# Iterate through the list of unused images
for image_id in $unused_images; do
    # Get the creation time of the image
    image_created=$(docker inspect -f '{{.Created}}' "$image_id")

    # Check if the image creation time is earlier than the cutoff date
    if [[ "$image_created" < "$cutoff_date" ]]; then
        # Check if this image is being used in a container or service
        is_used=$(docker ps -a --format "{{.Image}}" | grep -c "$image_id")

        if [ $is_used -eq 0 ]; then
            # Remove the image if it's not in use
            echo "Removing image $image_id"
            docker rmi $image_id
        else
            echo "Not removing image $image_id because it is in use"
        fi
    fi
done
