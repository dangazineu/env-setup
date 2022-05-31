#!/bin/bash

set -e

if [ -z "$SUDO_USER" ]
then
  echo "You must use \`sudo\` to run this script"
  exit 1
fi

source functions.sh

install_command curl

CDN=https://dlcdn.apache.org/maven/maven-3/

if [ "$#" -eq 0 ]; then
  VERSION=$(curl -s $CDN | grep -o "3.[0-9].[0-9]" | sort -ru | head -n 1)
  echo "No Maven version was provided, so retrieved latest from download url: $VERSION"
else
  VERSION=$1
  echo "Using provided Maven version: $VERSION"
fi

if [ -z "$VERSION" ] ; then
  echo "Couldn't determine latest version to download"
  exit 1
fi

DIST_NAME=apache-maven-$VERSION
FILE_NAME=$DIST_NAME-bin.tar.gz
URL=$CDN/$VERSION/binaries/$FILE_NAME

install_from_url $URL "maven" $DIST_NAME
