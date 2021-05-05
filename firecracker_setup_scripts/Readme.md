### Configuring the VM

# Mount the rootfs.ext4 for the concerned vm on the host machine  
`sudo mount <path_to_rootfs.ext4> /mnt/<arbitrary_mount_point>`
# Take ownership of mounter device so you have access to it's root
`chown root /mnt/<arbitrary_mount_point>/root/.ssh`
# Copy the proposed user's  public ssh keys into  /root/.ssh/authorized_keys

`cat <path to public keys>  >> /root/.ssh/authorized_keys`

# Configure the open ssh server config

copy contents of the ssd_config file into /etc/ssh/sshd_config

# Add network config file to /root/.bashrc

copy content of guest.sh to a file in root
Set that file to run once the bash profile is setup

Add this line to the end of the .bashrc file

`sh <path_to_network_config_file>`

# Unmount rootfs

# Start firecracker
Do al host and vm config inside the start.sh file

`sh start.sh`
