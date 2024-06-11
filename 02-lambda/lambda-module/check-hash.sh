#!/bin/bash
folder_path="$1"
hash=$(find "$folder_path" -type f -exec shasum {} \; | shasum | awk '{ print $1 }')
echo "{\"hash\": \"$hash\"}"