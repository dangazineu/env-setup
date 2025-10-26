#!/bin/bash

set -e

source functions.sh
install_command curl unzip

case $(uname) in
  "Linux") OS=linux ;;
  "Darwin") OS=mac ;;
  *) echo "Unsupported OS" ; exit 1
esac

case $(uname -m) in
  "arm64"|"aarch64") ARCH=aarch64 ;;
  "x86_64") ARCH=x86_64 ;;
  *) echo "Unsupported architecture" ; exit 1
esac

case $OS in
  "linux")
    URL="https://awscli.amazonaws.com/awscli-exe-linux-$ARCH.zip"
    TMP_DIR=$(mktemp -d)
    TMP_FILE="$TMP_DIR/awscliv2.zip"

    echo "Downloading AWS CLI v2 from $URL"
    curl -s "$URL" -o "$TMP_FILE"

    unzip -q "$TMP_FILE" -d "$TMP_DIR"

    if ! is_sudo ; then
      echo "Installing AWS CLI (requires sudo)"
      sudo "$TMP_DIR/aws/install" --update
    else
      "$TMP_DIR/aws/install" --update
    fi

    rm -rf "$TMP_DIR"

    echo "AWS CLI installed successfully"
    aws --version
    ;;
  "mac")
    URL="https://awscli.amazonaws.com/AWSCLIV2.pkg"
    TMP_FILE=$(mktemp)

    echo "Downloading AWS CLI v2 from $URL"
    curl -s "$URL" -o "$TMP_FILE"

    if ! is_sudo ; then
      echo "Installing AWS CLI (requires sudo)"
      sudo installer -pkg "$TMP_FILE" -target /
    else
      installer -pkg "$TMP_FILE" -target /
    fi

    rm "$TMP_FILE"

    echo "AWS CLI installed successfully"
    aws --version
    ;;
esac
