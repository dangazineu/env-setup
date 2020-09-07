#!/bin/bash

set -e

if [ -z "$SUDO_USER" ]
then
  echo "\$SUDO_USER must be set for this script to function properly"
  exit 1
fi

apt install -y curl

echo "Preparing to install kubectl"
apt update && apt install -y apt-transport-https gnupg2
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list
apt update
apt install -y kubectl

echo "kubectl is installed"

apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virtinst virt-manager

systemctl is-active libvirtd

echo "KVM is active!"

usermod -aG libvirt $SUDO_USER
usermod -aG kvm $SUDO_USER

apt install bash-completion
KUBECTL_COMP=/etc/bash_completion.d/kubectl-completion

if [ -f $KUBECTL_COMP ] ; then
  echo "$KUBECTL_COMP already exists, deleting..."
  rm $KUBECTL_COMP
fi

cat <<EOF > $KUBECTL_COMP
source <(kubectl completion bash)
EOF
chmod 755 $KUBECTL_COMP
