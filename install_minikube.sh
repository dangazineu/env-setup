#!/bin/bash

set -e

./install_docker.sh
./install_kvm.sh
./install_kubectl.sh

curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \
  && chmod +x minikube

mkdir -p /usr/local/bin/
install minikube /usr/local/bin/
rm minikube

/usr/local/bin/minikube config set vm-driver kvm2

echo "Minikube is installed!"

