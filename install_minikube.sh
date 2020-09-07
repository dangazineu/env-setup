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

apt install bash-completion
MINIKUBE_COMP=/etc/bash_completion.d/minikube-completion

if [ -f $MINIKUBE_COMP ] ; then
  echo "$MINIKUBE_COMP already exists, deleting..."
  rm $MINIKUBE_COMP
fi
cat <<EOF > $MINIKUBE_COMP
source <(minikube completion bash)
EOF
chmod 755 $MINIKUBE_COMP

echo "Minikube is installed!"
echo "Now configure properties like:"
echo ""
echo "minikube config set vm-driver kvm2"
echo "minikube config set memory 12288"