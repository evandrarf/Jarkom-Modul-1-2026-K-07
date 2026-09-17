#!/bin/bash
# Menambahkan static route di router Lain
ip route add 10.67.1.0/24 dev eth1 proto kernel scope link src 10.67.1.1 || true
ip route add 10.67.2.0/24 dev eth2 proto kernel scope link src 10.67.2.1 || true
ip route add 10.67.3.0/24 dev eth3 proto kernel scope link src 10.67.3.1 || true
