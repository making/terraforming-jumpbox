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
