#!/bin/bash
set -e

directory=$(pwd)
if [[ $directory == *"/scripts" ]]; then
  cd ..
fi

golangci-lint run

echo "No linting errors"

