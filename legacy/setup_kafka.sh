



RELEASE_VERSION=v1.0.0
curl -LO https://github.com/operator-framework/operator-sdk/releases/download/${RELEASE_VERSION}/operator-sdk-${RELEASE_VERSION}-x86_64-linux-gnu
chmod +x operator-sdk-${RELEASE_VERSION}-x86_64-linux-gnu && sudo mkdir -p /usr/local/bin/ && sudo cp operator-sdk-${RELEASE_VERSION}-x86_64-linux-gnu /usr/local/bin/operator-sdk && rm operator-sdk-${RELEASE_VERSION}-x86_64-linux-gnu

#Installing Golang

wget https://golang.org/dl/go1.15.linux-amd64.tar.gz
tar -vxf go1.15.linux-amd64.tar.gz
sudo mv go /usr/local

sudo echo "export GOPATH=$HOME/work" >> ~/.profile
sudo echo "export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin" >> ~/.profile

#Evento Operator Creation Steps

mkdir -p $GOPATH/src/github.com/evento-oss/entity-operator
cd $GOPATH/src/github.com/evento-oss/entity-operator
operator-sdk init --domain=evento.dev --repo=github.com/evento-oss/entity-operator --license apache2 --owner "The Evento authors"
operator-sdk create api --group=evento --version=v1alpha1 --kind=Entity
operator-sdk create api --group=evento --version=v1alpha1 --kind=CommandDefinition
operator-sdk create api --group=evento --version=v1alpha1 --kind=EventDefinition

# Steps to install Strimzi Operator and create the Evento Kafka broker

mkdir strimzi
cd strimzi/
wget https://github.com/strimzi/strimzi-kafka-operator/releases/download/0.19.0/strimzi-0.19.0.tar.gz
tar -vxf strimzi-0.19.0.tar.gz
rm -Rf strimzi-0.19.0.tar.gz
cd strimzi-0.19.0/
cd install/cluster-operator/
kubectl create ns evento
kubectl create -f strimzi-admin/ -n evento
sed -i 's/namespace: .*/namespace: evento/' ./cluster-operator/*RoleBinding*.yaml
kubectl apply -f ./cluster-operator -n evento
cd ../examples/kafka/
kubectl apply -f examples/kafka/kafka-ephemeral.yaml -n evento