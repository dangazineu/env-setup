#!/bin/bash

set -e

source functions.sh
install_command jq wget

if [ "$#" -eq 0 ]; then
  VERSION=$(wget --quiet -O - https://go.dev/dl/?mode=json | jq -r '.[0].version' | sed 's/^go//')
  echo "No Go version was provided, default is latest stable: $VERSION"
else
  VERSION=$1
  echo "Using provided Go version: $VERSION"
fi

case $(uname) in
  "Linux") OS=linux ;;
  "Darwin") OS=darwin ;;
  *) echo "Unsupported OS" ; exit 1
esac

case $(uname -m) in
  "arm64") ARCH=arm64 ;;
  "x86_64") ARCH=amd64 ;;
  *) echo "Unsupported architecture" ; exit 1
esac

DIST_NAME=go$VERSION
FILE_NAME=$DIST_NAME.$OS-$ARCH.tar.gz
URL=https://go.dev/dl/$FILE_NAME

echo "Latest available release for Go $VERSION is: $DIST_NAME"

install_from_url $URL "go" "go"

