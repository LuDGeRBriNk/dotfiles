#!/bin/bash

# This script automates virt-manager configs.
# It requires whitelisting these commands in the sudoers file!

# Start required services
echo "Starting libvirt daemon..."
sudo systemctl start libvirtd

echo "Starting default network..."
sudo virsh net-start default

echo "Launching virt-manager..."
# The script will pause on this line until you close the virt-manager window
GDK_DPI_SCALE=1.4 virt-manager

echo "virt-manager closed. Cleaning up..."

#Stop required services
echo "Stopping default network..."
sudo virsh net-destroy default

echo "Stopping libvirt daemon..."
sudo systemctl stop libvirtd

echo "Done!"