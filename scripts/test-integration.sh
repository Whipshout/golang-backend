#!/bin/bash
set -e

directory=$(pwd)
if [[ $directory == *"/scripts" ]]; then
  cd ..
fi

docker-compose -f docker/test-integration/docker-compose.yml build
docker-compose -f docker/test-integration/docker-compose.yml up --force-recreate --abort-on-container-exit

CODE=0
docker-compose -f docker/test-integration/docker-compose.yml ps -q | xargs docker inspect -f '{{ .State.ExitCode }}' | while read code; do
    if [ "$code" == "1" ]; then
       CODE=-1
    fi
done
docker-compose -f docker/test-integration/docker-compose.yml down
exit $CODE