#!/bin/bash

# WARNING: This will erase ALL data on /dev/nvme0n1!
DEVICE="/dev/nvme0n1"

# Partition sizes (adjust if needed)
BOOT_SIZE="512M"
ROOTFS_SIZE="24G"
NODES=4

echo "=== Partitioning $DEVICE for $NODES nodes with A/B booting ==="

# Create new DOS partition table
echo "Creating new partition table..."
parted -s $DEVICE mklabel msdos

# Create partitions using sfdisk (more scriptable than fdisk)
echo "Creating partitions..."
sfdisk $DEVICE << EOF
,${BOOT_SIZE},c
,${ROOTFS_SIZE},83
,${BOOT_SIZE},c
,${ROOTFS_SIZE},83
,${BOOT_SIZE},c
,${ROOTFS_SIZE},83
,${BOOT_SIZE},c
,${ROOTFS_SIZE},83
,${BOOT_SIZE},c
,${ROOTFS_SIZE},83
,${BOOT_SIZE},c
,${ROOTFS_SIZE},83
,${BOOT_SIZE},c
,${ROOTFS_SIZE},83
,${BOOT_SIZE},c
,${ROOTFS_SIZE},83
,,83
EOF

# Refresh partition table
partprobe $DEVICE

# Format partitions
echo "Formatting partitions..."
for i in {1..16}; do
  if ((i % 4 == 1 || i % 4 == 3)); then  # Boot partitions (1,3,5,7...)
    mkfs.vfat -F32 ${DEVICE}p$i
  else  # RootFS partitions
    mkfs.ext4 -F ${DEVICE}p$i
  fi
done

# Format shared storage (last partition)
mkfs.ext4 -F ${DEVICE}p17

echo "=== Partitioning complete! ==="
echo "Final layout:"
fdisk -l $DEVICE
