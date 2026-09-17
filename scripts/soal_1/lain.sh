#!/bin/bash
cat << 'EOF' > /etc/network/interfaces
# -> Router Lain
auto eth0
iface eth0 inet dhcp

# Interface ke switch-1
auto eth1
iface eth1 inet static
    address 10.67.1.1
    netmask 255.255.255.0

# Interface ke switch-2
auto eth2
iface eth2 inet static
    address 10.67.2.1
    netmask 255.255.255.0

# Interface ke switch-3
auto eth3
iface eth3 inet static
    address 10.67.3.1
    netmask 255.255.255.0


EOF
