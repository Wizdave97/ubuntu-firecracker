#!/bin/bash
# Ignore
TAP_DEV="tap$1"
TAP_IP=`ip -4 addr show $TAP_DEV | grep -oP '(?<=inet\s)\d+(\.\d+){3}'`
DEFAULT_DEVICE=`route | grep '^default' | grep -o '[^ ]*$'`
DEFAULT_DEVICE_IP=`ip -4 addr show $DEFAULT_DEVICE | grep -oP '(?<=inet\s)\d+(\.\d+){3}'`
sudo iptables -A FORWARD -i $DEFAULT_DEVICE -o $TAP_DEV -p tcp --syn --dport 500$1 -m conntrack --ctstate NEW -j ACCEPT
iptables -A FORWARD -i $DEFAULT_DEVICE  -o $TAP_DEV -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -i $TAP_DEV  -o $DEFAULT_DEVICE -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -t nat -A PREROUTING -i $DEFAULT_DEVICE -p tcp --dport 500$1 -j DNAT --to-destination $TAP_IP:22
sudo iptables -t nat -A POSTROUTING -o $TAP_DEV -p tcp --dport 5000 -d $DEFAULT_DEVICE_IP -j SNAT --to-source $TAP_IP:22



