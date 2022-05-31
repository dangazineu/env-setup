#!/bin/bash

set -e

if [ -z "$SUDO_USER" ]
then
  echo "\$SUDO_USER must be set for this script to function properly"
  exit 1
fi

VERSION=0.9.2

wget https://github.com/wagoodman/dive/releases/download/v${VERSION}/dive_${VERSION}_linux_amd64.deb

apt install -y ./dive_${VERSION}_linux_amd64.deb

rm -f dive_${VERSION}_linux_amd64.deb
