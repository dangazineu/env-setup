#!/bin/bash

set -e

if [ -z "$SUDO_USER" ]
then
  echo "\$SUDO_USER must be set for this script to function properly"
  exit 1
fi

# first installs dependencies
apt -qq install -y jq wget tar

if [ "$#" -eq 0 ]; then
  VERSION=$(wget --quiet -O - https://api.adoptium.net/v3/info/available_releases | jq '.most_recent_lts')
  echo "No Java version was provided, default is latest LTS: $VERSION"
else
  VERSION=$1
  echo "Using provided Java version: $VERSION"
fi

INFO=$(wget --quiet -O -  "https://api.adoptium.net/v3/assets/latest/$VERSION/hotspot?architecture=x64&image_type=jdk&os=linux&vendor=eclipse" | jq '.[0]' )

URL=$(echo $INFO | jq -r '.binary.package.link')

PRODUCT_NAME=java
DIST_NAME=$(echo $INFO | jq -r '.release_name')

echo "Latest available release for Java $VERSION is: $DIST_NAME"

# TODO: from here onwards, the code is mostly generic and can be reused
BASE_PATH=/usr/local
DEST_PATH=$BASE_PATH/$DIST_NAME

if [ -d $DEST_PATH ] ; then
  echo "$DEST_PATH already exists, deleting..."
  rm -r $DEST_PATH
fi

wget --quiet -O - $URL | tar -xzf - -C $BASE_PATH

ENV_FILE=/etc/profile.d/$PRODUCT_NAME-env.sh
if [ -f $ENV_FILE ] ; then
  echo "$ENV_FILE already exists, deleting..."
  rm $ENV_FILE
fi

cat <<EOF > $ENV_FILE
export PATH="$DEST_PATH/bin:\$PATH"
EOF

chmod 755 $ENV_FILE

echo ""
echo ""
echo "JDK installed. Run the following command to add it to your \$PATH in this session:"
echo ""
echo "source $ENV_FILE"
