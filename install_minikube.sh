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

apt install bash-completion

KUBE_ENV=/etc/profile.d/minikube-env.sh

if [ -f $KUBE_ENV ] ; then
  echo "$KUBE_ENV already exists, deleting..."
  rm $KUBE_ENV
fi

cat <<EOF > $KUBE_ENV
source <(minikube completion bash)
EOF

chmod 755 $KUBE_ENV

echo "Minikube is installed!"

    $
