#!/bin/bash

export TARGET

set -euo pipefail

# shellcheck source=/etc/os-release
. /etc/os-release

if [[ "$VERSION_ID" == 9* ]]
then
microdnf install -y dnf
dnf install 'dnf-command(config-manager)' -y
dnf config-manager --enable ol9_codeready_builder

tee /etc/yum.repos.d/ol9-epel.repo<<EOF
[ol9_developer_EPEL]
name= Oracle Linux \$releasever EPEL (\$basearch)
baseurl=https://yum.oracle.com/repo/OracleLinux/OL9/developer/EPEL/\$basearch/
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-oracle
gpgcheck=1
enabled=1
EOF
elif [[ "$VERSION_ID" == 8* ]]
then
microdnf install -y dnf
dnf install 'dnf-command(config-manager)' -y
dnf config-manager --enable ol8_codeready_builder
tee /etc/yum.repos.d/ol8-epel.repo<<EOF
[ol8_developer_EPEL]
name= Oracle Linux \$releasever EPEL (\$basearch)
baseurl=https://yum.oracle.com/repo/OracleLinux/OL8/developer/EPEL/\$basearch/
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-oracle
gpgcheck=1
enabled=1

[ol8_codeready_builder]
name=Oracle Linux 8 CodeReady Builder (\$basearch) - Unsupported
baseurl=https://yum.oracle.com/repo/OracleLinux/OL8/codeready/builder/\$basearch/
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-oracle
gpgcheck=1
enabled=1
EOF
else 
  echo "Unsupported OL version: $VERSION_ID"
  exit 1
fi
dnf update -y

dnf install -y \
  ImageMagick \
  file \
  sudo \
  net-tools \
  iputils \
  curl \
  git \
  jq \
  dos2unix \
  mysql \
  procps-ng \
  tzdata \
  rsync \
  nano \
  unzip \
  zstd \
  lbzip2 \
  libpcap \
  libwebp \
  findutils \
  which

bash /build/ol/install-gosu.sh

# Patched knockd
curl -fsSL -o /tmp/knock.tar.gz https://github.com/Metalcape/knock/releases/download/0.8.1/knock-0.8.1-$TARGET.tar.gz
tar -xf /tmp/knock.tar.gz -C /usr/local/ && rm /tmp/knock.tar.gz
ln -s /usr/local/sbin/knockd /usr/sbin/knockd
