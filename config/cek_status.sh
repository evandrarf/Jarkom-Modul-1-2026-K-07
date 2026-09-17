#!/bin/bash
echo "=== RINGKASAN INTERFACE ==="
ip -br a
echo ""
echo "=== TABEL NAT POSTROUTING ==="
iptables -t nat -L POSTROUTING -v -n