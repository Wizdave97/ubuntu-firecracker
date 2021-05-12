#!/bin/bash
# To create the first VM run start.sh 1
# To create another VM run start.sh 2 ..


#TAP_DEV should be created dynamically in future it should be unique for each VM on a host machine
TAP_DEV="tap$1"
DEFAULT_DEVICE=`route | grep '^default' | grep -o '[^ ]*$'`

MASK_LONG="255.255.255.252"
MASK_SHORT="/30"
# These IPs should be created dynamically also, should be unique for each VM on the entire server
FC_IP="169.254.0.2$1"
TAP_IP="printf '169.254.0.2%s' $(($1 + 1))"

# We'll ideally add the iptable rules for port forwarding here
# set up a tap network interface for the Firecracker VM to user
sudo ip link del "$TAP_DEV" 2> /dev/null || true
sudo ip tuntap add $TAP_DEV mode tap
sudo ip addr add $FC_IP$MASK_SHORT dev $TAP_DEV
sudo ip link set $TAP_DEV up
sudo sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"
sudo iptables -t nat -A POSTROUTING -o $DEFAULT_DEVICE -j MASQUERADE
sudo iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i $TAP_DEV -o $DEFAULT_DEVICE -j ACCEPT
FC_MAC=`cat /sys/class/net/${TAP_DEV}/address`


# set up the kernel boot args
KERNEL_BOOT_ARGS="init=/bin/systemd panic=1 pci=off reboot=k ipv6.disable=1 console=ttyS0"
KERNEL_BOOT_ARGS="${KERNEL_BOOT_ARGS} ip=${FC_IP}::${TAP_IP}:${MASK_LONG}::eth0:off"
rootfs_path=$(pwd)"/ubuntu.ext4"
kernel_path=$(pwd)"/vmlinux.bin"


# make a configuration file
cat <<EOF > vmconfig.json
{
  "boot-source": {
    "kernel_image_path": "$kernel_path",
    "boot_args": "$KERNEL_BOOT_ARGS"
  },
  "drives": [
    {
      "drive_id": "rootfs",
      "path_on_host": "$rootfs_path",
      "is_root_device": true,
      "is_read_only": false
    }
  ],
  "network-interfaces": [
      {
          "iface_id": "eth0",
          "guest_mac": "$FC_MAC",
          "host_dev_name": "$TAP_DEV"
      }
  ],
   "machine-config": {
    "vcpu_count": 4,
    "mem_size_mib": 1024,
    "ht_enabled": false
  }
}
EOF

# start firecracker
./firecracker --no-api --config-file vmconfig.json