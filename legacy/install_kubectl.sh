#!/bin/bash

set -e

if [ -z "$SUDO_USER" ]
then
  echo "\$SUDO_USER must be set for this script to function properly"
  exit 1
fi

apt install -y curl

echo "kubectl: Installing prerequisites"
apt update && apt install -y apt-transport-https ca-certificates curl gnupg2
sudo mkdir -p -m 755 /etc/apt/keyrings || true
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg # allow unprivileged APT programs to read this keyring


# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list   # helps tools such as command-not-found to work correctly
apt update

echo "kubectl: Installing kubectl"
apt install -y kubectl

echo "kubectl: Installing bash completion"
apt install bash-completion
KUBECTL_COMP=/etc/bash_completion.d/kubectl-completion

if [ -f $KUBECTL_COMP ] ; then
  echo "kubectl:  $KUBECTL_COMP already exists, deleting..."
  rm $KUBECTL_COMP
fi

cat <<EOF > $KUBECTL_COMP
source <(kubectl completion bash)
EOF
chmod 755 $KUBECTL_COMP

echo "kubectl: Done"