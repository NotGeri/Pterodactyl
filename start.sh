#!/usr/bin/env bash

# Check if we should build the image
if ! docker images | grep -q pterodactyl-panel; then
  if ! docker build -t pterodactyl-panel .; then
    echo "Unable to build image"
    exit 1
  fi
fi

# Check if we have panel files
if [ ! -d ./files ]; then
  echo "No panel files found in 'files'"
  exit 1
fi

if [ ! -f ./files/.env ]; then
  echo "No panel .env file found"
  exit 1
fi

docker-compose --file docker-compose.yml --project-name pterodactyl up "$@"