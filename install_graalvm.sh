#!/bin/bash

set -e

source functions.sh
install_command jq wget

if [ "$#" -eq 0 ]; then
  VERSION=$(get_latest_github_release "graalvm/graalvm-ce-builds" | sed 's/^jdk-//')
  echo "No GraalVM version was provided, default is latest stable: $VERSION"
else
  VERSION=$1
  echo "Using provided GraalVM version: $VERSION"
fi

case $(uname) in
  "Linux") OS=linux ;;
  "Darwin") OS=macos ;;
  *) echo "Unsupported OS" ; exit 1
esac

case $(uname -m) in
  "arm64") ARCH=aarch64 ;;
  "x86_64") ARCH=x64 ;;
  *) echo "Unsupported architecture" ; exit 1
esac

# GraalVM uses jdk- prefix in tags
TAG_VERSION=jdk-$VERSION
DIST_NAME=graalvm-community-jdk-$VERSION
FILE_NAME=graalvm-community-jdk-${VERSION}_${OS}-${ARCH}_bin.tar.gz
URL=https://github.com/graalvm/graalvm-ce-builds/releases/download/$TAG_VERSION/$FILE_NAME

echo "Latest available release for GraalVM $VERSION is: $DIST_NAME"

# Install build dependencies
case $(uname) in
  "Linux")
    install_command build-essential libz-dev zlib1g-dev
    ;;
  "Darwin")
    # macOS typically has these tools pre-installed
    ;;
esac

# Install GraalVM using the common framework
install_from_url $URL "graalvm" $DIST_NAME

# Install native-image component
GRAALVM_HOME=/opt/$DIST_NAME
if [ -f "$GRAALVM_HOME/bin/gu" ]; then
  echo "Installing native-image component..."
  if ! is_sudo ; then
    sudo $GRAALVM_HOME/bin/gu install native-image
  else
    $GRAALVM_HOME/bin/gu install native-image
  fi
  echo "Native-image component installed successfully"
else
  echo "Warning: gu utility not found at $GRAALVM_HOME/bin/gu"
fi
