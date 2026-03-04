#!/bin/bash

# This script automates virt-manager configs.
# It REQUIRES whitelisting these commands in the sudoers file!

# Start required services
echo "Starting libvirt daemon..."
sudo /usr/bin/systemctl start libvirtd

echo "Starting default network..."
sudo /usr/bin/virsh net-start default

echo "Launching virt-manager..."
# The script will pause on this line until you close the virt-manager window
GDK_DPI_SCALE=1.4 virt-manager

echo "virt-manager closed. Cleaning up..."

#Stop required services
echo "Stopping default network..."
sudo /usr/bin/virsh net-destroy default

echo "Stopping libvirt daemon..."
sudo /usr/bin/systemctl stop libvirtd

echo "Done!"