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
MINIKUBE_ENV=/etc/profile.d/minikube-env.sh

if [ -f $MINIKUBE_ENV ] ; then
  echo "$MINIKUBE_ENV already exists, deleting..."
  rm $MINIKUBE_ENV
fi

cat <<EOF > $MINIKUBE_ENV
source <(minikube completion bash)
EOF
chmod 755 $MINIKUBE_ENV

echo "Minikube is installed!"

    $
