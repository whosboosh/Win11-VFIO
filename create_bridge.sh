ip link add name br0 type bridge
ip link set dev br0 up
ip link set enp6s0 up
ip link set enp6s0 master br0
ip addr flush dev enp6s0
dhclient -r
dhclient br0
