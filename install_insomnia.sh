#!/bin/bash

set -e

if [ -z "$SUDO_USER" ]
then
  echo "\$SUDO_USER must be set for this script to function properly"
  exit 1
fi


# Add to sources
echo "deb https://dl.bintray.com/getinsomnia/Insomnia /" \
    | sudo tee -a /etc/apt/sources.list.d/insomnia.list

# Add public key used to verify code signature
wget --quiet -O - https://insomnia.rest/keys/debian-public.key.asc \
    | sudo apt-key add -

# Refresh repository sources and install Insomnia
apt update
apt install insomnia