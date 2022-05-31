#!/bin/bash

set -e

if [ -z "$SUDO_USER" ]
then
  echo "\$SUDO_USER must be set for this script to function properly"
  exit 1
fi

# get latest version from https://www.azul.com/downloads/?version=java-11-lts&package=jdk
JAVA_VERSION=zulu11.52.13-ca-jdk11.0.13-linux_x64
JAVA_BASE_PATH=/usr/lib
JAVA_HOME=$JAVA_BASE_PATH/java
JAVA_DIR=$JAVA_BASE_PATH/$JAVA_VERSION

TGZ=https://cdn.azul.com/zulu/bin/$JAVA_VERSION.tar.gz

if [ -d $JAVA_DIR ] ; then
  echo "$JAVA_DIR already exists, deleting..."
  rm -r $JAVA_DIR
fi

wget --quiet -O - $TGZ | tar -xzf - -C $JAVA_BASE_PATH

if [ -L "$JAVA_HOME" ] ; then
  echo "$JAVA_HOME already exists, deleting..."
  rm $JAVA_HOME
fi

ln -s $JAVA_DIR $JAVA_HOME

JAVA_ENV=/etc/profile.d/java-env.sh

if [ -f $JAVA_ENV ] ; then
  echo "$JAVA_ENV already exists, deleting..."
  rm $JAVA_ENV
fi

cat <<EOF > $JAVA_ENV 
#Setup JAVA_HOME path
export JAVA_HOME="$JAVA_HOME"
export PATH="\$JAVA_HOME/bin:\$PATH"
EOF

chmod 755 $JAVA_ENV

echo ""
echo ""
echo "JDK installed. Run the following command to add it to your \$PATH in this session:"
echo ""
echo "source $JAVA_ENV"
