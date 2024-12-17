#!/bin/bash

set -e

if [ -z "$SUDO_USER" ]
then
  echo "\$SUDO_USER must be set for this script to function properly"
  exit 1
fi

echo "KVM: Installing prerequisites"
apt install -y curl

echo "KVM: Installing KVM"
apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virtinst virt-manager

echo "KVM: Configuring users"
usermod -aG libvirt "$SUDO_USER"
usermod -aG kvm "$SUDO_USER"

echo "KVM: Enabling services"
systemctl enable libvirtd
echo "KVM: Done"