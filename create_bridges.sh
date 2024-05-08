dhclient -r enp6s0
ip addr flush dev enp6s0
ip link add br0 type bridge
ip link set enp6s0 master br0
dhclient br0
