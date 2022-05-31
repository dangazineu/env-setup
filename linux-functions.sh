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

  ENV_FILE=/etc/profile.d/$PROGRAM_NAME.sh
  if [ -f $ENV_FILE ] ; then
    rm $ENV_FILE
  fi

cat <<EOF > $ENV_FILE
    export PATH="$PROGRAM_PATH:\$PATH"
EOF

  chmod 755 $ENV_FILE
  echo $ENV_FILE
}
