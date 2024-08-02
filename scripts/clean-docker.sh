#!/bin/bash
set -e

directory=$(pwd)
if [[ $directory == *"/scripts" ]]; then
  cd ..
fi

docker-compose -f docker/dev/docker-compose.yml down --rmi all --volumes --remove-orphans
docker-compose -f docker/test-integration/docker-compose.yml down --rmi all --volumes --remove-orphans