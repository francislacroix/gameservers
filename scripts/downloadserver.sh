#!/bin/bash

# Prepare a named parameter for the server type
servertype=""

# Get the named parameter
while getopts ":t" opt; do
    case $opt in
        t) servertype="$OPTARG" ;;
    esac
done

# Validate required parameters
if [[ -z "$servertype" ]]; then
    echo "Error: The -t <servertype> parameter is required." >&2
    usage
fi

curl -O https://raw.githubusercontent.com/francislacroix/gameservers/refs/heads/main/servers/$servertype/.env.sample
curl -O https://raw.githubusercontent.com/francislacroix/gameservers/refs/heads/main/servers/$servertype/Dockerfile
curl -O https://raw.githubusercontent.com/francislacroix/gameservers/refs/heads/main/servers/$servertype/compose.yaml

mv .env.sample .env