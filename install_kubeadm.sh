#!/bin/bash

set -e

swapoff -a

modprobe br_netfilter

cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

apt update && apt install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF | tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt update
apt install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

systemctl daemon-reload
systemctl restart kubelet

#https://help.ubuntu.com/community/NetworkManager
apt-get install network-manager

cat <<EOF | tee /etc/NetworkManager/conf.d/calico.conf 
[keyfile]
unmanaged-devices=interface-name:cali*;interface-name:tunl*;interface-name:vxlan.calico
EOF

systemctl start NetworkManager.service
systemctl enable NetworkManager.service

kubeadm init --pod-network-cidr=192.168.0.0/16

#https://docs.projectcalico.org/getting-started/kubernetes/quickstart
#https://raaaimund.github.io/tech/2018/10/23/create-single-node-k8s-cluster/

#to run on my account
#mkdir $HOME/.k8s
#sudo cp /etc/kubernetes/admin.conf $HOME/.k8s/
#sudo chown $(id -u):$(id -g) $HOME/.k8s/admin.conf
#export KUBECONFIG=$HOME/.k8s/admin.conf
#echo "export KUBECONFIG=$HOME/.k8s/admin.conf" | tee -a ~/.bashrc
