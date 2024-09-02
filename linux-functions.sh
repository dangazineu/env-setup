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
    local CHMOD_CMD="chmod"
    local SUDO_CMD=""
  else
    local RM_CMD="sudo rm"
    local CAT_CMD="sudo cat"
    local SUDO_CMD="sudo"
  fi


  ENV_FILE=/etc/profile.d/$PROGRAM_NAME.sh
  if [ -f $ENV_FILE ] ; then
    $SUDO_CMD rm $ENV_FILE
  fi

#$SUDO_CMD cat <<EOF > $ENV_FILE
#    export PATH="$PROGRAM_PATH:\$PATH"
#EOF

  $SUDO_CMD bash -c "echo export PATH=\\\"$PROGRAM_PATH:\\\$PATH\\\" > $ENV_FILE"
  $SUDO_CMD chmod 755 $ENV_FILE
  echo $ENV_FILE
}
