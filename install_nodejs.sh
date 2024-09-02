#!/bin/bash

# https://nodejs.org/en/

set -e

source functions.sh

install_command curl

CDN=https://nodejs.org/dist

VERSION=18.14.1
DIST_NAME=node-v$VERSION-linux-x64
FILE_NAME=$DIST_NAME.tar.xz

URL=$CDN/v$VERSION/$FILE_NAME

install_from_url $URL "nodejs" $DIST_NAME