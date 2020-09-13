#!/bin/bash

MAVEN_FILE_NAME=$1

MAVEN_VERSION=$(echo $MAVEN_FILE_NAME | grep -Po '(?<=apache-maven-)[^-]+')
MAVEN_FOLDER=apache-maven-$MAVEN_VERSION
MAVEN_BASE_PATH=/usr/local
MAVEN_DIR=$MAVEN_BASE_PATH/$MAVEN_FOLDER
M2_HOME=$MAVEN_BASE_PATH/maven

echo "Installing Maven $MAVEN_VERSION from $MAVEN_FILE_NAME"
if [ -d $MAVEN_DIR ] ; then
  echo "$MAVEN_DIR already exists, deleting..."
  rm -r $MAVEN_DIR
fi
tar -xzf $MAVEN_FILE_NAME -C $MAVEN_BASE_PATH

if [ -L "$M2_HOME" ] ; then
  echo "$M2_HOME already exists, deleting..."
  rm $M2_HOME
fi
ln -s $MAVEN_BASE_PATH/$MAVEN_FOLDER $M2_HOME

MAVEN_ENV=/etc/profile.d/maven-env.sh
if [ -f $MAVEN_ENV ] ; then
  echo "$MAVEN_ENV already exists, deleting..."
  rm $MAVEN_ENV
fi

cat <<EOF > $MAVEN_ENV
#Setup M2_HOME path
export M2_HOME="$M2_HOME"
export PATH="\$M2_HOME/bin:\$PATH"
EOF

chmod 755 $MAVEN_ENV
