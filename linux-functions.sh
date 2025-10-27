#!/bin/bash

function install_package {
  if ! [ -x "$(command -v apt)" ]; then
    echo "apt is not supported in this environment"
    exit 1
  fi

  for var in "$@" ; do
    apt -qq install -y $var
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
    local CAT_CMD="cat"
    local BASH_CMD="bash"
    local CHMOD_CMD="chmod"
    local SUDO_CMD=""
  else
    local RM_CMD="sudo rm"
    local CAT_CMD="sudo cat"
    local BASH_CMD="sudo bash"
    local CHMOD_CMD="sudo chmod"
    local SUDO_CMD="sudo"
  fi


  ENV_FILE=/etc/profile.d/$PROGRAM_NAME.sh
  if [ -f $ENV_FILE ] ; then
    $RM_CMD $ENV_FILE
  fi

  $BASH_CMD -c "cat <<'EOF' > $ENV_FILE
export PATH=$PROGRAM_PATH:\$PATH
EOF"

  $CHMOD_CMD 755 $ENV_FILE
  echo $ENV_FILE
}
