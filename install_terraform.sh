#!/bin/bash
# This script only works for linux_amd64 for now.

set -e

source functions.sh

install_command curl unzip

CDN=https://releases.hashicorp.com/terraform
#https://releases.hashicorp.com/terraform/1.3.7/terraform_1.3.7_linux_amd64.zip

if [ "$#" -eq 0 ]; then
  VERSION=$(curl -s "$CDN/" \
  | grep -v "alpha" | grep -v "beta" | grep -v "rc" \
  | grep -o "terraform_[0-9].[0-9].[0-9]" \
  | sort -ru \
  | grep -o "[0-9].[0-9].[0-9]" \
  | head -n 1)
  echo "No version was provided, so retrieved latest from download url: $VERSION"
else
  VERSION=$1
  echo "Using provided version: $VERSION"
fi

if [ -z "$VERSION" ] ; then
  echo "Couldn't determine latest version to download"
  exit 1
fi

DIST_NAME="terraform_$VERSION"
ARCH_NAME="_linux_amd64"
URL="$CDN/$VERSION/$DIST_NAME$ARCH_NAME.zip"
echo "Package url is $URL"

BASE_PATH=/opt
DEST_PATH=$BASE_PATH/$DIST_NAME
TMP_FILE="$(mktemp).zip"

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

$MK_CMD $DEST_PATH

curl $URL -o $TMP_FILE
$UNZIP_CMD -d $DEST_PATH $TMP_FILE
rm $TMP_FILE

ENV_FILE=$(add_to_path "terraform" "$DEST_PATH")
echo "Created $ENV_FILE"
