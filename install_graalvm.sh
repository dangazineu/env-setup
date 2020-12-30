#!/bin/bash

TGZ=$1

apt install build-essential libz-dev zlib1g-dev -y

#TODO parse this from filename
GRAALVM_VERSION=graalvm-ce-java11-20.3.0
GRAALVM_BASE_PATH=/usr/lib
GRAALVM_HOME=$GRAALVM_BASE_PATH/graalvm
GRAALVM_DIR=$GRAALVM_BASE_PATH/$GRAALVM_VERSION

echo "Installing $GRAALVM_VERSION from $TGZ"

if [ -d $GRAALVM_DIR ] ; then
  echo "$GRAALVM_DIR already exists, deleting..."
  rm -r $GRAALVM_DIR
fi

tar -xzf $TGZ -C $GRAALVM_BASE_PATH

if [ -L "$GRAALVM_HOME" ] ; then
  echo "$GRAALVM_HOME already exists, deleting..."
  rm $GRAALVM_HOME
fi

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
