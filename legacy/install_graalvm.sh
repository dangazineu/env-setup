#!/bin/bash

# https://www.graalvm.org/downloads/

VERSION=21.3.0
DIST_NAME=graalvm-ce-java11-$VERSION
FILE_NAME=graalvm-ce-java11-linux-amd64-$VERSION.tar.gz

TGZ=https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-$VERSION/$FILE_NAME

apt install build-essential libz-dev zlib1g-dev -y

#TODO parse this from filename
GRAALVM_VERSION=$DIST_NAME
GRAALVM_BASE_PATH=/usr/lib
GRAALVM_HOME=$GRAALVM_BASE_PATH/graalvm
GRAALVM_DIR=$GRAALVM_BASE_PATH/$GRAALVM_VERSION

echo "Installing $GRAALVM_VERSION from $TGZ"

if [ -d $GRAALVM_DIR ] ; then
  echo "$GRAALVM_DIR already exists, deleting..."
  rm -r $GRAALVM_DIR
fi

if [ -L "$GRAALVM_HOME" ] ; then
  echo "$GRAALVM_HOME already exists, deleting..."
  rm $GRAALVM_HOME
fi

wget --quiet -O - $TGZ | tar -xzf - -C $GRAALVM_BASE_PATH

ln -s $GRAALVM_DIR $GRAALVM_HOME

GRAALVM_ENV=/etc/profile.d/graalvm-env.sh

if [ -f $GRAALVM_ENV ] ; then
  echo "$GRAALVM_ENV already exists, deleting..."
  rm $GRAALVM_ENV
fi

cat <<EOF > $GRAALVM_ENV
#Setup GRAALVM_HOME path
export GRAALVM_HOME="$GRAALVM_HOME"
EOF

$GRAALVM_HOME/bin/gu install native-image

chmod 755 $GRAALVM_ENV

echo ""
echo ""
echo "GRAALVM installed. Run the following command to add it to your \$PATH in this session:"
echo ""
echo "source $GRAALVM_ENV"
