#!/bin/bash

OS_FUNCTIONS=$(uname | tr '[:upper:]' '[:lower:]')-functions.sh

if [ -f "$OS_FUNCTIONS" ]; then
  source $OS_FUNCTIONS
else
  echo "Couldn't find $OS_FUNCTIONS. This OS isn't supported"
  exit 1
fi

# This function assumes the command name is used as the name of the package.
# This is true for all cases in this project so far.
function install_command {
  for c in "$@" ; do
    if ! [ -x "$(command -v $c)" ]; then
      install_package $c
    fi
  done
}

function install_from_url {
  install_command wget tar

  if [ "$#" -ne 3 ]; then
    echo "This function expects exactly 3 parameters"
    exit 1
  fi

  local URL=$1
  local PROGRAM_NAME=$2
  local DIST_NAME=$3

  BASE_PATH=/opt
  DEST_PATH=$BASE_PATH/$DIST_NAME

  echo "Package url is $URL"

  if [ -d $DEST_PATH ] ; then
    echo "Replacing contents on $DEST_PATH"
    rm -r $DEST_PATH
  else
    echo "Installing on $DEST_PATH"
  fi

  wget --quiet -O - $URL | tar -xzf - -C $BASE_PATH

  ENV_FILE=$(add_to_path $PROGRAM_NAME "$DEST_PATH/bin")
  echo "Created $ENV_FILE"
}
