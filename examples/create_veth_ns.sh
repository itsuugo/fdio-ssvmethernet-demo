#!/usr/bin/env bash

while getopts ":n:m:i:g:" opt; do
    case $opt in
    n)
        NAMESPACE=$OPTARG
        ;;
    m)
        MAC=$OPTARG
        ;;
    i)
        IP=$OPTARG
        ;;
    g)
        GW=$OPTARG
        ;;
    esac
done

if [ -z "$NAMESPACE" ]; then
    echo "Usage: create_veth_ns -n NAMESPACE [-i IP] [-m MAC] [-g GW]"
    exit 1
fi

set -xe

DP_INTERFACE=${NAMESPACE}dp
NS_INTERFACE=${NAMESPACE}ns

ip netns add $NAMESPACE
ip link add name $DP_INTERFACE type veth peer name $NS_INTERFACE
ip link set netns $NAMESPACE dev $NS_INTERFACE
ip link set up $DP_INTERFACE
ip netns exec $NAMESPACE ip link set up dev lo
ip netns exec $NAMESPACE ip link set up dev $NS_INTERFACE
ip netns exec $NAMESPACE ethtool -K $NS_INTERFACE rx off tx off

if [ -n "$IP" ]; then
        if [ "$IP" == "dhcp" ]; then
          ip netns exec $NAMESPACE dhclient -nw -v \
          -pf /tmp/dhclient$NAMESPACE.pid \
          -lf /tmp/dhclient$NAMESPACE.lease $NS_INTERFACE
        else
          ip netns exec $NAMESPACE ip address add $IP dev $NS_INTERFACE
        fi
fi

if [ -n "$MAC" ]; then
    ip netns exec $NAMESPACE ip link set address $MAC dev $NS_INTERFACE
fi

if [ -n "$GW" ]; then
    ip netns exec $NAMESPACE ip route add default via $GW
fi
