#!/bin/bash
set -e

directory=$(pwd)
if [[ $directory == *"/scripts" ]]; then
  cd ..
fi

docker-compose -p tests -f docker/test-integration/docker-compose.yml build --no-cache
docker-compose -p tests -f docker/test-integration/docker-compose.yml up --force-recreate --abort-on-container-exit --exit-code-from tester || (echo "Tests failed. Showing logs:" && docker-compose -p tests -f docker/test-integration/docker-compose.yml logs)
EXIT_CODE=$?

docker-compose -p tests -f docker/test-integration/docker-compose.yml down
exit $EXIT_CODE