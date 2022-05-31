#!/bin/bash

set -e

if [ -z "$SUDO_USER" ]
then
  echo "\$SUDO_USER must be set for this script to function properly"
  exit 1
fi

apt install -y curl

apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virtinst virt-manager

usermod -aG libvirt $SUDO_USER
usermod -aG kvm $SUDO_USER

systemctl is-active libvirtd

echo "KVM is active!"