#!/bin/bash

set -e

if [ -z "$SUDO_USER" ]
then
  echo "\$SUDO_USER must be set for this script to function properly"
  exit 1
fi

apt remove -y docker docker-engine docker.io containerd runc || true

echo "Installing tools..."

apt update && apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

apt update 

apt install -y  docker-ce docker-ce-cli containerd.io 

groupadd docker || true
usermod -aG docker $SUDO_USER

systemctl enable docker

