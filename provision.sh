#!/bin/bash
set -exuo pipefail

PROVISION=/share/provison

mkdir -p ${PROVISION}

if [ ! -f ${PROVISION}/apt-get ];then
  sudo apt-get update && \
  sudo apt-get install -y \
    build-essential \
    zlibc \
    zlib1g-dev \
    ruby \
    ruby-dev \
    openssl \
    libxslt1-dev \
    libxml2-dev \
    libssl-dev \
    libreadline7 \
    libreadline-dev \
    libyaml-dev \
    libsqlite3-dev \
    sqlite3 \
    jq \
    awscli
  touch ${PROVISION}/apt-get
fi

if [ ! -f ${PROVISION}/kubectl ];then
  KUBECTL_VERSION=1.16.7
  wget -q -O kubectl "https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && \
    sudo install kubectl /usr/local/bin/ && \
    rm -f kubectl*
  touch ${PROVISION}/kubectl
fi

if [ ! -f ${PROVISION}/helm ];then
  HELM_VERSION=3.2.4
  wget -q -O helm.tgz "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz" && \
    tar xzf helm.tgz && \
    sudo install linux-amd64/helm /usr/local/bin/ && \
    rm -rf linux-amd64* helm.tgz
  touch ${PROVISION}/helm
fi

if [ ! -f ${PROVISION}/k14s ];then
  curl -L https://k14s.io/install.sh | sudo bash
  touch ${PROVISION}/k14s
fi

if [ ! -f ${PROVISION}/cf-cli ];then
  CF_CLI_VERSION=6.51.0
  wget -q -O cf.tgz "https://packages.cloudfoundry.org/stable?release=linux64-binary&version=${CF_CLI_VERSION}&source=github-rel" && \
    tar xzf cf.tgz && \
    sudo install cf /usr/local/bin/ && \
    rm -f cf* LICENSE NOTICE
  touch ${PROVISION}/cf-cli
fi

if [ ! -f ${PROVISION}/bosh-cli ];then
  BOSH_VERSION=6.3.0
  wget -q -O bosh https://github.com/cloudfoundry/bosh-cli/releases/download/v${BOSH_VERSION}/bosh-cli-${BOSH_VERSION}-linux-amd64 && \
    sudo install bosh /usr/local/bin/ && \
    rm -f bosh*
  touch ${PROVISION}/bosh-cli
fi

if [ ! -f ${PROVISION}/om ];then
  OM_VERSION=5.0.0
  wget -q -O om https://github.com/pivotal-cf/om/releases/download/${OM_VERSION}/om-linux-${OM_VERSION} && \
    sudo install om /usr/local/bin/ && \
    rm -f om*
  touch ${PROVISION}/om
fi

if [ ! -f ${PROVISION}/pivnet ];then
  PIVNET_VERSION=1.0.4
  wget -q -O pivnet https://github.com/pivotal-cf/pivnet-cli/releases/download/v${PIVNET_VERSION}/pivnet-linux-amd64-${PIVNET_VERSION} && \
    sudo install pivnet /usr/local/bin/ && \
    rm -f pivnet*
  touch ${PROVISION}/pivnet
fi

if [ ! -f ${PROVISION}/terraform ];then
  TERRAFORM_VERSION=0.12.26
  wget -q -O terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform.zip && \
    sudo install terraform /usr/local/bin/ && \
    rm -f terraform* terraform.zip
  touch ${PROVISION}/terraform
fi

if [ ! -f ${PROVISION}/credhub ];then
  CREDHUB_VERSION=2.7.0
  wget -q -O credhub.tgz https://github.com/cloudfoundry-incubator/credhub-cli/releases/download/${CREDHUB_VERSION}/credhub-linux-${CREDHUB_VERSION}.tgz && \
    tar xzf credhub.tgz && \
    sudo install credhub /usr/local/bin/ && \
    rm -f credhub*
  touch ${PROVISION}/credhub
fi

if [ ! -f ${PROVISION}/bbr ];then
  BBR_VERSION=1.7.2
  wget -q -O bbr https://github.com/cloudfoundry-incubator/bosh-backup-and-restore/releases/download/v${BBR_VERSION}/bbr-${BBR_VERSION}-linux-amd64 && \
    sudo install bbr /usr/local/bin/ && \
    rm -f bbr*
  touch ${PROVISION}/bbr
fi

if [ ! -f ${PROVISION}/uaac ];then
  sudo gem install cf-uaac
  touch ${PROVISION}/uaac
fi

if [ ! -f ${PROVISION}/lego ];then
  LEGO_VERSION=3.7.0
  wget -q -O lego.tgz https://github.com/go-acme/lego/releases/download/v${LEGO_VERSION}/lego_v${LEGO_VERSION}_linux_amd64.tar.gz && \
    tar xzf lego.tgz && \
    sudo install lego /usr/local/bin && \
    rm -f lego* CHANGELOG.md lego
  touch ${PROVISION}/lego
fi

if [ ! -f ${PROVISION}/yj ];then
  YJ_VERSION=4.0.0
  wget -q -O yj https://github.com/sclevine/yj/releases/download/v${YJ_VERSION}/yj-linux && \
    sudo install yj /usr/local/bin/ && \
    rm -f yj*
  touch ${PROVISION}/yj
fi

if [ ! -f ${PROVISION}/openjdk ];then
  wget -q -O OpenJDK.tar.gz https://github.com/bell-sw/Liberica/releases/download/11.0.7%2B10/bellsoft-jdk11.0.7+10-linux-amd64.tar.gz && \
    tar xzf OpenJDK.tar.gz && \
    sudo mv jdk-* /share/ && \
    rm -f OpenJDK.tar.gz && \
    cat <<EOF | sudo tee /etc/profile.d/01-openjdk.sh
export JAVA_HOME=$(dirname /share/jdk-*/bin/)
export PATH=\${PATH}:\${JAVA_HOME}/bin
EOF
  touch ${PROVISION}/openjdk
fi

if [ ! -f ${PROVISION}/maven ];then
  MAVEN_VERSION=3.6.3
  wget -q -O maven.tar.gz http://ftp.riken.jp/net/apache/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz && \
    tar xzf maven.tar.gz && \
    sudo mv apache-maven-* /share/ && \
    rm -f maven.tar.gz && \
    cat <<EOF | sudo tee /etc/profile.d/02-maven.sh
export MAVEN_HOME=/share/apache-maven-${MAVEN_VERSION}
export PATH=\${PATH}:\${MAVEN_HOME}/bin
EOF
  touch ${PROVISION}/maven
fi

if [ ! -f ${PROVISION}/docker-repo ];then
  echo "==== Setup docker repo ===="
  sudo apt-get remove -y docker docker-engine docker.io containerd runc
  sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  sudo apt-get update -y
  touch ${PROVISION}/docker-repo
fi

if [ ! -f ${PROVISION}/docker ];then
  DOCKER_VERSION=5:19.03.8~3-0~ubuntu-bionic
  CONTAINERD_VERSION=1.2.13-1
  # install docker
  sudo apt-get remove -y docker docker-engine docker.io containerd runc
  sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  sudo apt-get update -y
  sudo apt-get install -y docker-ce=${DOCKER_VERSION} docker-ce-cli=${DOCKER_VERSION} containerd.io=${CONTAINERD_VERSION}
  sudo systemctl enable docker && sudo systemctl start docker
  sudo usermod -aG docker ubuntu
  sudo apt-mark hold docker-ce docker-ce-cli containerd.io

  sudo mkdir -p /etc/docker
  cat <<'EOF' | sudo tee -a /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF

  # Restart Docker
  sudo systemctl daemon-reload
  sudo systemctl restart docker
  touch ${PROVISION}/docker
fi
