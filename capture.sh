#!/usr/bin/env bash

host=$1
USER="amir"
MAIN_ETH="ens33"
program_name="./scripts/$host"
PCAP_DIR="pcaps/"

NS=$2
VETH=$3
VPEER=$4
VETH_ADDR=$5
VPEER_ADDR=$6

if [[ $EUID -ne 0 ]]; then
    echo "You must be root to run this script"
    exit 1
fi

# Create namespace
ip netns add $NS

sleep 1

mkdir -p /etc/netns/${NS}/
echo "nameserver 8.8.8.8" > /etc/netns/${NS}/resolv.conf
echo "nameserver 8.8.4.4" >> /etc/netns/${NS}/resolv.conf

# Create veth link.
ip link add ${VETH} type veth peer name ${VPEER}

# Add peer-1 to NS.
ip link set ${VPEER} netns $NS

# Setup IP address of ${VETH}.
ip addr add ${VETH_ADDR}/24 dev ${VETH}
ip link set ${VETH} up

# Setup IP ${VPEER}.
ip netns exec $NS ip addr add ${VPEER_ADDR}/24 dev ${VPEER}
ip netns exec $NS ip link set ${VPEER} up
ip netns exec $NS ip link set lo up
ip netns exec $NS ip route add default via ${VETH_ADDR}

# Enable IP-forwarding.
echo 1 > /proc/sys/net/ipv4/ip_forward

# Enable masquerading of 10.200.1.0.
iptables -t nat -A POSTROUTING -s ${VPEER_ADDR}/24 -o ${MAIN_ETH} -j MASQUERADE
 
iptables -A FORWARD -i ${MAIN_ETH} -o ${VETH} -j ACCEPT
iptables -A FORWARD -o ${MAIN_ETH} -i ${VETH} -j ACCEPT

sleep 1
# Run the program within namespace
ip netns exec $NS sudo -u $USER "$program_name" &

tcpdump -U -i $VETH -w "$PCAP_DIR$host".pcap &
