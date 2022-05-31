#!/bin/bash

set -e

if [ -z "$SUDO_USER" ]
then
  echo "\$SUDO_USER must be set for this script to function properly"
  exit 1
fi

# first installs dependencies
apt -qq install -y jq wget tar

if [ "$#" -eq 0 ]; then
  VERSION=$(wget --quiet -O - https://api.adoptium.net/v3/info/available_releases | jq '.most_recent_lts')
  echo "No Java version was provided, default is latest LTS: $VERSION"
else
  VERSION=$1
  echo "Using provided Java version: $VERSION"
fi

INFO=$(wget --quiet -O -  "https://api.adoptium.net/v3/assets/latest/$VERSION/hotspot?architecture=x64&image_type=jdk&os=linux&vendor=eclipse" | jq '.[0]' )

URL=$(echo $INFO | jq -r '.binary.package.link')

DIST_NAME=$(echo $INFO | jq -r '.release_name')

echo "Latest available release for Java $VERSION is: $DIST_NAME"

source functions.sh

install_from_url $URL "java" $DIST_NAME

