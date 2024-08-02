#!/bin/bash
set -e

directory=$(pwd)
if [[ $directory == *"/scripts" ]]; then
  cd ..
fi

docker-compose -p tests -f docker/test-integration/docker-compose.yml build
docker-compose -p tests -f docker/test-integration/docker-compose.yml up --force-recreate --abort-on-container-exit

docker-compose -p tests -f docker/test-integration/docker-compose.yml down

exit 0