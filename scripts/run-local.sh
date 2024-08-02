#!/bin/bash
set -e

directory=$(pwd)
if [[ $directory == *"/scripts" ]]; then
  cd ..
fi

CGO_ENABLED=0 GOOS=linux go build -o ./bin/server ./cmd/server

./bin/server