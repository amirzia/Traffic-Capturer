#!/bin/bash

rm -rf dbs/ pcaps/

VETHS=$(sudo ip link show type veth | grep -o "veth[0-9]*")
NSs=$(sudo ip netns list | grep -o "ns[0-9]*")

for veth in $VETHS
do
	sudo ip link delete $veth
done

for ns in $NSs
do
	sudo ip netns delete $ns
done

sleep 1

kill -2 $(pgrep tcpdump)

