#!/bin/bash

# Prepare a named parameter for the server type
servertype=""

# Get the named parameter
while getopts ":t:" opt; do
    case $opt in
        t) servertype="$OPTARG" ;;
        :) echo "Error: Option -$OPTARG requires an argument." >&2; exit 1 ;;
        \?) echo "Error: Invalid option -$OPTARG" >&2; exit 1 ;;
    esac
done

# Validate required parameters
if [[ -z "$servertype" ]]; then
    echo "Error: The -t <servertype> parameter is required." >&2
    exit 1
fi

# Create a directory for the server type if it doesn't exist
mkdir -p servers/$servertype
cd servers/$servertype

# Download the necessary files for the specified server type
curl -O https://raw.githubusercontent.com/francislacroix/gameservers/refs/heads/main/servers/$servertype/.env.sample
curl -O https://raw.githubusercontent.com/francislacroix/gameservers/refs/heads/main/servers/$servertype/Dockerfile
curl -O https://raw.githubusercontent.com/francislacroix/gameservers/refs/heads/main/servers/$servertype/compose.yaml

# Rename the downloaded .env.sample file to .env
mv ./.env.sample ./.env