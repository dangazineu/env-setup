#!/bin/bash

set -e

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

curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \
  && chmod +x minikube

mkdir -p /usr/local/bin/
install minikube /usr/local/bin/

echo "Minikube is installed!"

