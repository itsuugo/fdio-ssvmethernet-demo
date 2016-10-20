#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive 

RELEASE=$1
UBUNTU="xenial"

sysctl -w vm.nr_hugepages=1024
HUGEPAGES=`sysctl -n  vm.nr_hugepages`
if [ $HUGEPAGES != 1024 ]; then
    echo "ERROR: Unable to get 1024 hugepages, only got $HUGEPAGES.  Cannot finish."
    exit
fi

rm /etc/apt/sources.list.d/99fd.io.list
echo "deb [trusted=yes] https://nexus.fd.io/content/repositories/fd.io$RELEASE.ubuntu.$UBUNTU.main/ ./" | sudo tee -a /etc/apt/sources.list.d/99fd.io.list
apt-get -qq update
apt-get -qq install -y docker.io tmux uuid screen netperf git
apt-get -qq install -y vpp vpp-dpdk-dkms dkms
apt-get -qq install -y linux-headers-$(uname -r)
modprobe -v igb_uio
usermod -aG docker vagrant
systemctl start vpp
