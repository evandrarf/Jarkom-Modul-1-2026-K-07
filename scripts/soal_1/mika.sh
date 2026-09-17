#!/bin/bash
cat << 'EOF' > /etc/network/interfaces
auto eth0
iface eth0 inet static
	address 10.67.1.3
	netmask 255.255.255.0
	gateway 10.67.1.1
EOF
