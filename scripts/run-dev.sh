#!/bin/bash
set -e

function cleanup {
  docker-compose -p dev -f docker/dev/docker-compose.yml down
  exit 0
}

trap cleanup SIGINT

directory=$(pwd)
if [[ $directory == *"/scripts" ]]; then
  cd ..
fi

docker-compose -p dev -f docker/dev/docker-compose.yml up --build --no-cache --abort-on-container-exit

cleanup