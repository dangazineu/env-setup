#!/bin/bash

set -e

source functions.sh

if [ "$(uname | tr '[:upper:]' '[:lower:]')" != "linux" ]; then
  echo "This script is only supported on Linux"
  exit 1
fi

install_command curl

CDN=https://go.dev/dl

if [ "$#" -eq 0 ]; then
  VERSION=$(curl -s "$CDN/" | \
  grep "download" | \
  grep -o "go[0-9]\{1,2\}\.[0-9]\{1,2\}\.[0-9]\{1,2\}\." | \
  grep -o "[0-9]\{1,2\}\.[0-9]\{1,2\}\.[0-9]\{1,2\}" | \
  sort -ruV | \
  head -n 1)

  echo "No version was provided, so retrieved latest from download url: $VERSION"
else
  VERSION=$1
  echo "Using provided version: $VERSION"
fi

if [ -z "$VERSION" ] ; then
  echo "Couldn't determine latest version to download"
  exit 1
fi

DIST_NAME=go$VERSION
FILE_NAME=$DIST_NAME.linux-amd64.tar.gz
URL=$CDN/$FILE_NAME

install_from_url "$URL" "go" "go"

