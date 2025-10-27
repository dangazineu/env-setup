#!/bin/bash

set -e

source functions.sh

if [ "$#" -eq 0 ]; then
  VERSION=$(get_latest_github_release "eksctl-io/eksctl")
  echo "No eksctl version was provided, default is latest: $VERSION"
else
  VERSION=$1
  echo "Using provided eksctl version: $VERSION"
fi

case $(uname) in
  "Linux") OS=Linux ;;
  "Darwin") OS=Darwin ;;
  *) echo "Unsupported OS" ; exit 1
esac

case $(uname -m) in
  "arm64") ARCH=arm64 ;;
  "x86_64") ARCH=amd64 ;;
  *) echo "Unsupported architecture" ; exit 1
esac

DIST_NAME=eksctl-$VERSION
FILE_NAME=eksctl_${OS}_${ARCH}.tar.gz
URL="https://github.com/eksctl-io/eksctl/releases/download/v${VERSION}/${FILE_NAME}"

echo "Latest available release for eksctl $VERSION is: $DIST_NAME"
echo "Package url is $URL"

BASE_PATH=/opt
DEST_PATH=$BASE_PATH/$DIST_NAME
TMP_FILE=$(mktemp)

install_command wget tar

if ! is_sudo ; then
  TAR_CMD="sudo tar"
  RM_CMD="sudo rm"
  MK_CMD="sudo mkdir"
else
  TAR_CMD="tar"
  RM_CMD="rm"
  MK_CMD="mkdir"
fi

if [ -d $DEST_PATH ] ; then
  echo "Replacing contents on $DEST_PATH"
  $RM_CMD -r $DEST_PATH
fi

$MK_CMD -p $DEST_PATH

wget --quiet -O $TMP_FILE $URL
$TAR_CMD -xzf $TMP_FILE -C $DEST_PATH
rm $TMP_FILE

ENV_FILE=$(add_to_path "eksctl" "$DEST_PATH")
echo "Created $ENV_FILE"
