#!/bin/bash

set -e

source functions.sh
install_command wget

if [ "$#" -eq 0 ]; then
  VERSION=$(wget --quiet -O - https://dl.k8s.io/release/stable.txt | sed 's/^v//')
  echo "No kubectl version was provided, default is latest stable: $VERSION"
else
  VERSION=$1
  echo "Using provided kubectl version: $VERSION"
fi

case $(uname) in
  "Linux") OS=linux ;;
  "Darwin") OS=darwin ;;
  *) echo "Unsupported OS" ; exit 1
esac

case $(uname -m) in
  "arm64"|"aarch64") ARCH=arm64 ;;
  "x86_64") ARCH=amd64 ;;
  *) echo "Unsupported architecture" ; exit 1
esac

DIST_NAME=kubectl-$VERSION
URL=https://dl.k8s.io/release/v$VERSION/bin/$OS/$ARCH/kubectl

echo "Downloading kubectl $VERSION for $OS/$ARCH"
echo "Package url is $URL"

BASE_PATH=/opt
DEST_PATH=$BASE_PATH/$DIST_NAME

if ! is_sudo ; then
  SUDO_CMD="sudo"
  MKDIR_CMD="sudo mkdir"
  WGET_CMD="sudo wget"
  CHMOD_CMD="sudo chmod"
else
  SUDO_CMD=""
  MKDIR_CMD="mkdir"
  WGET_CMD="wget"
  CHMOD_CMD="chmod"
fi

if [ -d $DEST_PATH ] ; then
  echo "Replacing contents on $DEST_PATH"
  $SUDO_CMD rm -r $DEST_PATH
else
  echo "Installing on $DEST_PATH"
fi

$MKDIR_CMD -p $DEST_PATH
$WGET_CMD --quiet -O $DEST_PATH/kubectl $URL
$CHMOD_CMD +x $DEST_PATH/kubectl

ENV_FILE=$(add_to_path kubectl "$DEST_PATH")
echo "Created $ENV_FILE"

echo "kubectl installed successfully"
$DEST_PATH/kubectl version --client
