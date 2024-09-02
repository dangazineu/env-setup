#!/bin/bash

set -e

#if [ -z "$SUDO_USER" ]
#then
#  echo "\$SUDO_USER must be set for this script to function properly"
#  exit 1
#fi

#curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
#apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

#apt update
#apt install vagrant -y

# copied from https://developer.hashicorp.com/vagrant/downloads
# TODO: integrate with generic functions
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vagrant
