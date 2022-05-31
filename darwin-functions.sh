#!/bin/bash

function install_package {
  if ! [ -x "$(command -v brew)" ]; then
    echo "brew is not supported in this environment"
    exit 1
  fi

  for var in "$@" ; do
    brew install $var
  done
}

function add_to_path {
  if [ "$#" -ne 2 ]; then
    echo "This function expects exactly 2 parameters"
    exit 1
  fi

  local PROGRAM_NAME=$1
  local PROGRAM_PATH=$2

  if is_sudo ; then
    local RM_CMD="rm"
    local BASH_CMD="bash"
  else
    local RM_CMD="sudo rm"
    local BASH_CMD="sudo bash"
  fi

  ENV_FILE=/etc/paths.d/$PROGRAM_NAME
  if [ -f $ENV_FILE ] ; then
    $RM_CMD $ENV_FILE
  fi

  $BASH_CMD -c "echo $PROGRAM_PATH > $ENV_FILE"

  echo $ENV_FILE
}
