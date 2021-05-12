#!/bin/bash
#TAP_IP and FC_IP should be the same as those set in the kernel arguments 
#This script should be run on startup
#Name server should be the name-server address of the host environment
MASK_SHORT="/30"
TAP_IP="169.254.0.22"
FC_IP="169.254.0.21"
NAME_SERVER="8.8.8.8"

ip addr add dev eth0 $TAP_IP$MASK_SHORT
ip route add default via $FC_IP && echo "nameserver ${NAME_SERVER}" > /etc/resolv.conf
chmod 0600 /root/.ssh/authorized_keys