#!/bin/bash

set -e

source functions.sh

if [ "$#" -eq 0 ]; then
  VERSION=$(get_latest_github_release "cli/cli")
  echo "No version was provided, default is latest: $VERSION"
else
  VERSION=$1
  echo "Using provided version: $VERSION"
fi

case $(uname) in
  "Linux") OS=linux ;;
  "Darwin") OS=macOS ;;
  *) echo "Unsupported OS" ; exit 1
esac

case $(uname -m) in
  "arm64") ARCH=arm64 ;;
  "x86_64") ARCH=amd64 ;;
  *) echo "Unsupported architecture" ; exit 1
esac

DIST_NAME=gh_${VERSION}_${OS}_${ARCH}

case $OS in
  "macOS")
    FILE_NAME=${DIST_NAME}.zip
    URL="https://github.com/cli/cli/releases/download/v${VERSION}/${FILE_NAME}"
    echo "Latest available release for gh $VERSION is: $DIST_NAME"

    # Download and extract the zip file
    install_command unzip
    TMP_FILE="$(mktemp).zip"

    BASE_PATH=/opt
    DEST_PATH=$BASE_PATH/$DIST_NAME

    if ! is_sudo ; then
      UNZIP_CMD="sudo unzip"
      RM_CMD="sudo rm"
      MK_CMD="sudo mkdir"
    else
      UNZIP_CMD="unzip"
      RM_CMD="rm"
      MK_CMD="mkdir"
    fi

    if [ -d $DEST_PATH ] ; then
      echo "Replacing contents on $DEST_PATH"
      $RM_CMD -r $DEST_PATH
    fi

    $MK_CMD -p $DEST_PATH

    echo "Package url is $URL"
    wget --quiet -O $TMP_FILE $URL
    $UNZIP_CMD -q -d $DEST_PATH $TMP_FILE
    rm $TMP_FILE

    ENV_FILE=$(add_to_path "gh" "$DEST_PATH/bin")
    echo "Created $ENV_FILE"
    ;;
  "linux")
    FILE_NAME=${DIST_NAME}.tar.gz
    URL="https://github.com/cli/cli/releases/download/v${VERSION}/${FILE_NAME}"
    echo "Latest available release for gh $VERSION is: $DIST_NAME"
    install_from_url $URL "gh" $DIST_NAME
    ;;
esac
