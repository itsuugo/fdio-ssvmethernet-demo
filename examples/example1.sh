#!/bin/bash

# Based on https://wiki.fd.io/view/VPP/Tutorial_Routing_and_Switching

# Configure ns0 and ns1 with veth
ip netns add ns0
ip link add vpp0 type veth peer name vethns0
ip link set vethns0 netns ns0
ip netns exec ns0 ip link set lo up
ip netns exec ns0 ip link set vethns0 up
ip netns exec ns0 ip addr add 2001::1/64 dev vethns0
ip netns exec ns0 ip addr add 10.0.0.1/24 dev vethns0
ip netns exec ns0 ethtool -K vethns0 rx off tx off
ip link set vpp0 up

ip netns add ns1
ip link add vpp1 type veth peer name vethns1
ip link set vethns1 netns ns1
ip netns exec ns1 ip link set lo up
ip netns exec ns1 ip link set vethns1 up
ip netns exec ns1 ip addr add 2001::2/64 dev vethns1
ip netns exec ns1 ip addr add 10.0.0.2/24 dev vethns1
ip netns exec ns1 ethtool -K vethns1 rx off tx off
ip link set vpp1 up

vppctl create host-interface name vpp0
vppctl create host-interface name vpp1
vppctl set interface state host-vpp0 up
vppctl set interface state host-vpp1 up

# Configure TAP interface 

vppctl tap connect tap0

ip netns add ns2
ip link set tap0 netns ns2
ip netns exec ns2 ip link set lo up
ip netns exec ns2 ip link set tap0 up
ip netns exec ns2 ip addr add 10.0.1.1/24 dev tap0
ip netns exec ns2 ip addr add 2001:1::1/64 dev tap0

# Configure routing and switching

# Switching ns0 and ns1

vppctl set interface l2 bridge host-vpp0 1
vppctl set interface l2 bridge host-vpp1 1

# Create loopback interface

vppctl create loopback interface
vppctl set interface l2 bridge loop0 1 bvi
vppctl set interface state loop0 up

vppctl set interface ip address loop0 2001::ffff/64
vppctl set interface ip address loop0 10.0.0.10/24

# Enable routing

vppctl set interface state tap-0 up
vppctl set interface ip address tap-0 2001:1::ffff/64
vppctl set interface ip address tap-0 10.0.1.10/24

# Setup routes
ip netns exec ns0 ip route add default via 10.0.0.10
ip netns exec ns0 ip -6 route add default via 2001::ffff
ip netns exec ns1 ip route add default via 10.0.0.10
ip netns exec ns1 ip -6 route add default via 2001::ffff
ip netns exec ns2 ip route add default via 10.0.1.10
ip netns exec ns2 ip -6 route add default via 2001:1::ffff

# Check
vppctl trace add af-packet-input 15
ip netns exec ns0 ping6 2001:1::1
ip netns exec ns0 ping 10.0.1.1
vppctl show trace
vppctl clear trace
