#!/bin/bash

function install_from_url {

  if [ "$#" -ne 3 ]; then
    echo "This function expects exactly 3 parameters"
    exit 1
  fi

  local URL=$1
  local PRODUCT_NAME=$2
  local DIST_NAME=$3

  BASE_PATH=/opt
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
  echo "Run the following command to add it to your \$PATH in this session:"
  echo ""
  echo "source $ENV_FILE"
}
