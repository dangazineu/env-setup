#!/bin/bash

set -e

if [ -z "$SUDO_USER" ]
then
  echo "You must use \`sudo\` to run this script"
  exit 1
fi

CDN=https://dlcdn.apache.org/maven/maven-3/
VERSION=$(curl -s $CDN | grep -o "3.[0-9].[0-9]" | sort -ru | head -n 1)

if [ -z "$VERSION" ] ; then
  echo "Couldn't determine latest version to download"
  exit 1
fi

PROJECT_NAME=maven
DIST_NAME=apache-$PROJECT_NAME-$VERSION
FILE_NAME=$DIST_NAME-bin.tar.gz
URL=$CDN/$VERSION/binaries/$FILE_NAME

BASE_PATH=/usr/local
DEST_PATH=$BASE_PATH/$DIST_NAME

if [ -d $DEST_PATH ] ; then
  echo "$DEST_PATH already exists, deleting..."
  rm -r $DEST_PATH
fi

wget --quiet -O - $URL | tar -xzf - -C $BASE_PATH

ENV_FILE=/etc/profile.d/$PROJECT_NAME-env.sh
if [ -f $ENV_FILE ] ; then
  echo "$ENV_FILE already exists, deleting..."
  rm $ENV_FILE
fi

cat <<EOF > $ENV_FILE
export PATH="$DEST_PATH/bin:\$PATH"
EOF

chmod 755 $ENV_FILE
