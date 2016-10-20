# Intro

This is a vagrant environment for testing several functionalities in FD.IO's VPP.

By default, it creates 2 VMs
- Ubuntu 16.04
- 2 vCPUs
- 4G of RAM
- 3 NICs (1 x NAT - host access, 2 x VPP DPDK enabled)

The VMs have docker installed

References:

https://wiki.fd.io/view/VPP

Tap and Veth interfaces
https://wiki.fd.io/view/VPP/Tutorial_Routing_and_Switching

DPDK Interfaces
https://wiki.fd.io/view/VPP/How_To_Connect_A_PCI_Interface_To_VPP

VXLAN
https://wiki.fd.io/view/VPP/Using_VPP_as_a_VXLAN_Tunnel_Terminator

Troubleshooting

vppctl trace add af-packet-input
vppctl trace add dpdk-input 
