#!/bin/bash

set -e

source functions.sh
install_command jq wget

if [ "$#" -eq 0 ]; then
  VERSION=$(wget --quiet -O - https://api.adoptium.net/v3/info/available_releases | jq '.most_recent_lts')
  echo "No Java version was provided, default is latest LTS: $VERSION"
else
  VERSION=$1
  echo "Using provided Java version: $VERSION"
fi

case $(uname) in
  "Linux") OS=linux ;;
  "Darwin") OS=mac ;;
  *) echo "Unsupported OS" ; exit 1
esac

case $(uname -m) in
  "arm64") ARCH=aarch64 ;;
  "x86_64") ARCH=x64 ;;
  *) echo "Unsupported architecture" ; exit 1
esac

INFO=$(wget --quiet -O -  "https://api.adoptium.net/v3/assets/latest/$VERSION/hotspot?architecture=$ARCH&image_type=jdk&os=$OS&vendor=eclipse" | jq '.[0]' )

URL=$(echo $INFO | jq -r '.binary.package.link')

DIST_NAME=$(echo $INFO | jq -r '.release_name')

echo "Latest available release for Java $VERSION is: $DIST_NAME"

case $OS in
  "mac")
    BASE_PATH="/Library/Java/JavaVirtualMachines" 
    install_from_url $URL "java" $DIST_NAME "$BASE_PATH" "Contents/Home/bin" 
    for JAVA_DIR in /Library/Java/JavaVirtualMachines/*/ ; do
      if [ "$JAVA_DIR" != "$BASE_PATH/$DIST_NAME/" ] ; then
        INFO_PLIST="$JAVA_DIR/Contents/Info.plist"
        if [ -f $INFO_PLIST ] ; then
          sudo mv $INFO_PLIST "$INFO_PLIST.disabled"
        fi
      fi
    done
    ;;
  "linux") install_from_url $URL "java" $DIST_NAME ;;
esac
