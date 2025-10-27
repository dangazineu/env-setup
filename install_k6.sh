#!/bin/bash

set -e

source functions.sh
install_command jq wget

if [ "$#" -eq 0 ]; then
  VERSION=$(get_latest_github_release "grafana/k6")
  echo "No k6 version was provided, default is latest stable: $VERSION"
else
  VERSION=$1
  echo "Using provided k6 version: $VERSION"
fi

case $(uname) in
  "Linux") OS=linux ;;
  "Darwin") OS=macos ;;
  *) echo "Unsupported OS" ; exit 1
esac

case $(uname -m) in
  "arm64"|"aarch64") ARCH=arm64 ;;
  "x86_64") ARCH=amd64 ;;
  *) echo "Unsupported architecture" ; exit 1
esac

DIST_NAME=k6-v$VERSION
FILE_NAME=$DIST_NAME-$OS-$ARCH

echo "Installing k6 $VERSION for $OS-$ARCH"

case $OS in
  "linux")
    install_command tar
    URL=https://github.com/grafana/k6/releases/download/v$VERSION/$FILE_NAME.tar.gz
    TMP_DIR=$(mktemp -d)
    TMP_FILE="$TMP_DIR/k6.tar.gz"

    echo "Package url is $URL"
    wget --quiet -O "$TMP_FILE" "$URL"

    tar -xzf "$TMP_FILE" -C "$TMP_DIR"

    DEST_PATH=/opt/$FILE_NAME

    if ! is_sudo ; then
      RM_CMD="sudo rm"
      MKDIR_CMD="sudo mkdir"
      MV_CMD="sudo mv"
    else
      RM_CMD="rm"
      MKDIR_CMD="mkdir"
      MV_CMD="mv"
    fi

    if [ -d $DEST_PATH ] ; then
      echo "Replacing contents on $DEST_PATH"
      $RM_CMD -r $DEST_PATH
    else
      echo "Installing on $DEST_PATH"
    fi

    $MKDIR_CMD -p $DEST_PATH
    $MV_CMD "$TMP_DIR/$FILE_NAME/k6" "$DEST_PATH/"

    rm -rf "$TMP_DIR"

    ENV_FILE=$(add_to_path "k6" "$DEST_PATH")
    echo "Created $ENV_FILE"
    ;;
  "macos")
    install_command unzip
    URL=https://github.com/grafana/k6/releases/download/v$VERSION/$FILE_NAME.zip
    TMP_DIR=$(mktemp -d)
    TMP_FILE="$TMP_DIR/k6.zip"

    echo "Package url is $URL"
    wget --quiet -O "$TMP_FILE" "$URL"

    unzip -q "$TMP_FILE" -d "$TMP_DIR"

    DEST_PATH=/opt/$FILE_NAME

    if ! is_sudo ; then
      RM_CMD="sudo rm"
      MKDIR_CMD="sudo mkdir"
      MV_CMD="sudo mv"
    else
      RM_CMD="rm"
      MKDIR_CMD="mkdir"
      MV_CMD="mv"
    fi

    if [ -d $DEST_PATH ] ; then
      echo "Replacing contents on $DEST_PATH"
      $RM_CMD -r $DEST_PATH
    else
      echo "Installing on $DEST_PATH"
    fi

    $MKDIR_CMD -p $DEST_PATH
    $MV_CMD "$TMP_DIR/$FILE_NAME/k6" "$DEST_PATH/"

    rm -rf "$TMP_DIR"

    ENV_FILE=$(add_to_path "k6" "$DEST_PATH")
    echo "Created $ENV_FILE"
    ;;
esac
