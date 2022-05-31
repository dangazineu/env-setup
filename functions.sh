#!/bin/bash

OS_FUNCTIONS=$(uname | tr '[:upper:]' '[:lower:]')-functions.sh

if [ -f "$OS_FUNCTIONS" ]; then
  source $OS_FUNCTIONS
else
  echo "Couldn't find $OS_FUNCTIONS. This OS isn't supported"
  exit 1
fi

function is_sudo {
  ! [ -z "$SUDO_USER" ] && return
}

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

  if [ "$#" -lt 3 ] ; then
    echo "This function expects exactly 3 parameters"
    exit 1
  fi

  local URL=$1
  local PROGRAM_NAME=$2
  local DIST_NAME=$3

  if [ "$#" -gt 3 ] ; then
    BASE_PATH=$4
  else
    BASE_PATH=/opt
  fi

  if [ "$#" -gt 4 ] ; then
    local PATH_SUFFIX=$5
  else
    local PATH_SUFFIX=bin
  fi

  DEST_PATH=$BASE_PATH/$DIST_NAME

  echo "Package url is $URL"

  if ! is_sudo ; then
    TAR_CMD="sudo tar"
    RM_CMD="sudo rm"
  else
    TAR_CMD="tar"
    RM_CMD="rm"
  fi

  if [ -d $DEST_PATH ] ; then
    echo "Replacing contents on $DEST_PATH"
    $RM_CMD -r $DEST_PATH
  else
    echo "Installing on $DEST_PATH"
  fi

  wget --quiet -O - $URL | $TAR_CMD -xzf - -C $BASE_PATH

  ENV_FILE=$(add_to_path $PROGRAM_NAME "$DEST_PATH/$PATH_SUFFIX")
  echo "Created $ENV_FILE"
}
