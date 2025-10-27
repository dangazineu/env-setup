#!/bin/bash

set -e

source functions.sh

if [ "$#" -eq 0 ]; then
  VERSION=$(get_latest_github_release "helm/helm")
  echo "No version was provided, default is latest: $VERSION"
else
  VERSION=$1
  echo "Using provided version: $VERSION"
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

DIST_NAME=helm-${VERSION}
FILE_NAME=helm-v${VERSION}-${OS}-${ARCH}.tar.gz
URL=https://get.helm.sh/${FILE_NAME}

echo "Latest available release for Helm $VERSION is: $DIST_NAME"

install_command wget tar

BASE_PATH=/opt
DEST_PATH=$BASE_PATH/$DIST_NAME

echo "Package url is $URL"

if ! is_sudo ; then
  TAR_CMD="sudo tar"
  RM_CMD="sudo rm"
  MV_CMD="sudo mv"
else
  TAR_CMD="tar"
  RM_CMD="rm"
  MV_CMD="mv"
fi

if [ -d $DEST_PATH ] ; then
  echo "Replacing contents on $DEST_PATH"
  $RM_CMD -r $DEST_PATH
else
  echo "Installing on $DEST_PATH"
fi

# Helm tar.gz extracts to a directory named ${OS}-${ARCH}/
# We need to extract and rename it to the desired destination
EXTRACTED_DIR=${OS}-${ARCH}
wget --quiet -O - $URL | $TAR_CMD -xzf - -C $BASE_PATH
$MV_CMD $BASE_PATH/$EXTRACTED_DIR $DEST_PATH

ENV_FILE=$(add_to_path "helm" "$DEST_PATH")
echo "Created $ENV_FILE"
