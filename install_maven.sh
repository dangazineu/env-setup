#!/bin/bash

MAVEN_FILE_NAME=$1

MAVEN_VERSION=$(echo $MAVEN_FILE_NAME | grep -Po '(?<=apache-maven-)[^-]+')
MAVEN_FOLDER=apache-maven-$MAVEN_VERSION
MAVEN_BASE_PATH=/usr/local
M2_HOME=$MAVEN_BASE_PATH/maven

echo "Installing Maven $MAVEN_VERSION from $MAVEN_FILE_NAME"

tar -xzf $MAVEN_FILE_NAME -C $MAVEN_BASE_PATH

ln -s $MAVEN_BASE_PATH/$MAVEN_FOLDER $M2_HOME

cat <<EOF > /etc/profile.d/maven-env.sh
#Setup M2_HOME path
export M2_HOME="$M2_HOME"
export PATH="\$M2_HOME/bin:\$PATH"
EOF

chmod 755 /etc/profile.d/maven-env.sh
