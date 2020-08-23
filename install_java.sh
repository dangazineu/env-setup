#!/bin/bash

TGZ=$1

JAVA_VERSION=jdk-$(echo $TGZ | grep -Po '(?<=jdk-)[^_]+')
JAVA_BASE_PATH=/usr/lib
JAVA_HOME=$JAVA_BASE_PATH/java
JAVA_DIR=$JAVA_BASE_PATH/$JAVA_VERSION

echo "Installing $JAVA_VERSION from $TGZ"

if [ -d $JAVA_DIR ] ; then
  echo "$JAVA_DIR already exists, deleting..."
  rm -r $JAVA_DIR
fi

tar -xzf $TGZ -C $JAVA_BASE_PATH

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
