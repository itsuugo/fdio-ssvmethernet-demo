#!/bin/bash

# Capture all the interface IPs, in case we need them later
ip -o addr show > ~vagrant/ifconfiga
chown vagrant:vagrant ~vagrant/ifconfiga

# Disable all ethernet interfaces other than the default route
# interface so VPP will use those interfaces.  The VPP auto-blacklist
# algorithm prevents the use of any physical interface contained in the
# routing table (i.e. "route --inet --inet6") preventing the theft of
# the management ethernet interface by VPP from the kernel.
for intf in $(ls /sys/class/net) ; do
    if [ -d /sys/class/net/$intf/device ] &&
        [ "$(route --inet --inet6 | grep default | grep $intf)" == "" ] ; then
        ifconfig $intf down
    fi
done

# Add dpkd interfaces, all pci interfaces but enp0s3 that's used for
# internet connectivity
echo "" >> /etc/vpp/startup.conf
echo 'dpdk {' >> /etc/vpp/startup.conf
echo 'socket-mem 1024' >> /etc/vpp/startup.conf
lshw -class network -businfo | grep pci | grep -v s3 | awk '{ print $1 }' | sed  's/pci@/dev /' >> /etc/vpp/startup.conf
echo '}' >> /etc/vpp/startup.conf

systemctl restart vpp
