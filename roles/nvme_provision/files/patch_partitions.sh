#!/usr/bin/env bash
set -euo pipefail

log() {
	local RED='\033[0;31m'
	local YELLOW='\033[0;33m'
	local GREEN='\033[0;32m'
	local NC='\033[0m'  # reset color
	local level=${1^^}  # upper case the log level

	case "$level" in
		ERROR) echo -e "${RED}$2${NC}" >&2;;
		WARN)  echo -e "${YELLOW}$2${NC}" >&2;;
		INFO)  echo -e "${GREEN}$2${NC}" >&2;;
		DEBUG) echo -e "${GREEN}$2${NC}" >&2;;
		*)     echo -e "${GREEN}$2${NC}" >&2;; # default to INFO
	esac
}

check_status() {
	local ret=$?

	if [ $ret -ne 0 ]; then
		log ERROR "Command failed (rc=$ret)"
		exit $ret
	fi
}

usage() {
	cat >&2 <<EOF
Usage:
  $0 --node 0|1|2|3 --slot a|b --mode local|nfs --boot <boot-partition> --root <root-partition>
        [--nfs-server <ip>] [--nfs-base <path>] [--password-hash <hash>]
        [--extra-groups <csv>] [--sudo-nopasswd 0|1]

Options:
  -n, --node    Node index (0..3)
  -s, --slot    Boot slot (a|b)
  -m, --mode    Operating mode:
                  local -> system boots from NVMe rootfs
                  nfs   -> system boots with rootfs over NFS
  -b, --boot    Path to boot partition device (e.g. /dev/nvme0n1p1)
  -r, --root    Path to rootfs partition device (e.g. /dev/nvme0n1p2)
  -h, --help    Show this help message

What it does:
  • Mounts the given boot and root partitions
  • Patches cmdline.txt (console + root device or NFS root)
  • Patches config.txt (ensures [all], uart0 enabled)
  • Touches 'ssh' in bootfs to enable SSH on first boot
  • Adds node-specific user (nodeX) with sudo privileges
  • Sets hostname (raspi-nodeX)
  • Updates /etc/fstab to match the chosen mode

Examples:
  Local NVMe boot (node0, slot a):
    $0 --node 0 --slot a --mode local --boot /dev/nvme0n1p1 --root /dev/nvme0n1p2

  NFS boot (node1, slot a):
    $0 --node 1 --slot a --mode nfs --boot /dev/nvme0n1p5 --root /dev/nvme0n1p6

Notes:
  - Run as root (mount and chroot required).
  - The partitions must already exist and be formatted.
  - NFS mode will patch cmdline.txt accordingly; fstab entries for NFS
    can be extended in patch_rootfs().
EOF
	exit 2
}

NODE=""         # 0..3
SLOT=""         # a|b
MODE=""         # local|nfs
BOOT=""         # e.g. /dev/nvme0n1pX
ROOT=""         # e.g. /dev/nvme0n1pX
NFS_SERVER="192.168.100.10"
NFS_EXPORT_BASE="/srv/nfs"  # final path becomes ${NFS_EXPORT_BASE}/node${NODE}
PASS_HASH=""                 # set with --password-hash (chpasswd -e format)
EXTRA_GROUPS="sudo,adm,video,render,plugdev,netdev"
SUDO_NOPASSWD=1


while [[ $# -gt 0 ]]; do
	case "$1" in
		-n|--node)  NODE="$2"; shift 2 ;;
		-s|--slot)  SLOT="$2"; shift 2 ;;
		-m|--mode)  MODE="$2"; shift 2 ;;
		-b|--boot)  BOOT="$2"; shift 2 ;;
        -r|--root)  ROOT="$2"; shift 2 ;;
        --nfs-server) NFS_SERVER="${2:-}"; shift 2;;
        --nfs-base)   NFS_EXPORT_BASE="${2:-}"; shift 2;;
        --password-hash) PASS_HASH="${2:-}"; shift 2;;
        --extra-groups)  EXTRA_GROUPS="${2:-}"; shift 2;;
        --sudo-nopasswd) SUDO_NOPASSWD="${2:-1}"; shift 2;;
		-h|--help) usage ;;
		*) log ERROR "Unknown arg: $1"; usage ;;
	esac
done

case "$NODE" in
	node[0-3])      NODE="${NODE#node}" ;;
	rpi-node[0-3])  NODE="${NODE#rpi-node}" ;;
esac
if [[ ! "$NODE" =~ ^[0-3]$ ]]; then
	log ERROR "--node must be 0..3";
	usage;
fi
if [[ ! "$SLOT" =~ ^[ab]$ ]]; then
	log ERROR "--slot must be a|b";
	usage;
fi
if [[ ! "$MODE" =~ ^(local|nfs)$ ]]; then
	log ERROR "--mode must be local|nfs";
	usage;
fi

NEW_USER="node${NODE}"
HOSTNAME="raspi-node${NODE}"
NFS_PATH="${NFS_EXPORT_BASE}/node${NODE}"

log INFO "Patching "$BOOT" partition for node${NODE}, slot [$SLOT], mode ${MODE}..."
patch_bootfs "$BOOT" "$ROOT" "$MODE"

log INFO "Patching "$ROOT" partition for node${NODE}, slot [$SLOT], mode ${MODE}..."
patch_rootfs "$BOOT" "$ROOT" "$MODE"

log INFO "Done for node${NODE} (slot ${SLOT}, mode ${MODE})"

patch_bootfs() {
    local BOOT_DEV="$1"
    local ROOT_DEV="$2"
    local MODE="$3"
    local BOOT_UUID=$(blkid -s PARTUUID -o value "$BOOT_DEV" 2>/dev/null || true)
    local ROOT_UUID=$(blkid -s PARTUUID -o value "$ROOT_DEV" 2>/dev/null || true)
    local TMP_MOUNT=$(mktemp -d)

    # Patch boot partition
    mount "$BOOT_DEV" "$TMP_MOUNT"
    if [[ ! -d "$TMP_MOUNT" ]]; then
        log ERROR "Failed to create temporary mount directory: $TMP_MOUNT"
        exit 1
    fi

    log INFO "Patching boot "$BOOT_DEV" "$TMP_MOUNT""

    log INFO "Patching cmdline.txt for node${NODE}"
    if [ -f "$TMP_MOUNT/cmdline.txt" ]; then
        if [[ $MODE == "local" ]]; then
            sed -i -E "s|root=[^ ]*|root=PARTUUID=${ROOT_UUID}|" "$TMP_MOUNT/cmdline.txt"
        else
            sed -i -E "s|root=[^ ]*|root=/dev/nfs nfsroot=${NFS_SERVER}:${NFS_PATH},vers=3|" "$TMP_MOUNT/cmdline.txt"
        fi
    else
        touch "$TMP_MOUNT/cmdline.txt"
        if [[ $MODE == "local" ]]; then
            echo "console=ttyAMA0,115200 console=tty1 root=PARTUUID=${ROOT_PARTUUID} rw rootfstype=ext4 rootwait" > "$TMP_MOUNT/cmdline.txt"
        else
            echo "console=ttyAMA0,115200 console=tty1 root=/dev/nfs nfsroot=${NFS_SERVER}:${NFS_PATH},vers=3 rw ip=dhcp rootfstype=ext4 rootwait" > "$TMP_MOUNT/cmdline.txt"
        fi
    fi

    # Replace if "console=serial0" with "ttyAMA0"
    sed -i -E 's/(console=)[^,]+/\1ttyAMA0/' "$TMP_MOUNT/cmdline.txt"

    # Set the ownership of cmdline.txt to the new user
    chroot "$TMP_MOUNT" chown -R "$NEW_USER:$NEW_USER" "$TMP_MOUNT/cmdline.txt"

    log INFO "Patching config.txt for node${NODE}"
    if [ -f "$TMP_MOUNT/config.txt" ]; then
        # Append `[all]` in case not found
        if ! grep -q "^\[all\]" "$TMP_MOUNT/config.txt"; then
            echo "[all]" | tee -a "$TMP_MOUNT/config.txt" > /dev/null
        fi

        # Append `dtparam=uart0=on` if it's not already present
        if ! grep -Fxq "dtparam=uart0=on" "$TMP_MOUNT/config.txt"; then
            echo "dtparam=uart0=on" | sudo tee -a "$TMP_MOUNT/config.txt" > /dev/null
        fi
    else
        log ERROR "Missing config.txt on boot partition";
        umount "$TMP_MOUNT"
        rm -rf "$TMP_MOUNT"
        exit 1
    fi

    # Create a new file on boot fs to enable ssh
    touch "$TMP_MOUNT/ssh"

    # Cleanup
    umount "$TMP_MOUNT"
    rm -rf "$TMP_MOUNT"
}

create_user_in_rootfs() {
  local root_mnt="$1"
  local user="$2"
  local pass_hash="$3"
  local extra_groups="$4"
  local sudo_nopasswd="$5"

# if chroot "$TMP_MOUNT" /usr/bin/getent passwd "$NEW_USER" >/dev/null 2>&1; then
#     log INFO "User $NEW_USER already exists — skipping creation"
# else
#     chroot "$TMP_MOUNT" /usr/sbin/useradd --create-home --shell /bin/bash "$NEW_USER" || true
#     echo "$NEW_USER:$NEW_USER" | chroot "$TMP_MOUNT" /usr/sbin/chpasswd || true
# fi

# # Add user to sudoers
# log INFO "Adding $NEW_USER to sudoers"
# echo "$NEW_USER ALL=(ALL) NOPASSWD: ALL" | tee -a "$TMP_MOUNT/etc/sudoers" > /dev/null

# # Set default shell to bash
# log INFO "Setting default shell for $NEW_USER to /bin/bash"
# chroot "$TMP_MOUNT" usermod -s /bin/bash "$NEW_USER"


  # Determine existing UID 1000 (if any)
  local uid1000
  uid1000="$(chroot "$root_mnt" getent passwd 1000 | cut -d: -f1 || true)"

  if chroot "$root_mnt" id "$user" >/dev/null 2>&1; then
    log INFO "User $user already exists in rootfs"
  else
    if [[ -n "$uid1000" && "$uid1000" != "$user" ]]; then
      log INFO "Renaming existing UID 1000 user '$uid1000' -> '$user'"
      chroot "$root_mnt" usermod -l "$user" "$uid1000"
      chroot "$root_mnt" usermod -m -d "/home/$user" "$user"
      chroot "$root_mnt" groupmod -n "$user" "$uid1000" 2>/dev/null || true
    else
      # Prefer UID 1000 if it is free
      if ! chroot "$root_mnt" getent passwd 1000 >/dev/null; then
        chroot "$root_mnt" useradd -m -u 1000 -s /bin/bash "$user"
      else
        chroot "$root_mnt" useradd -m -s /bin/bash "$user"
      fi
    fi
  fi

  # Password
  if [[ -n "$pass_hash" ]]; then
    echo "${user}:${pass_hash}" | chroot "$root_mnt" chpasswd -e
  else
    # default to user:user (only for lab; encourage real hash)
    echo "${user}:${user}" | chroot "$root_mnt" chpasswd || true
  fi

  # Groups
  chroot "$root_mnt" usermod -aG "$extra_groups" "$user" 2>/dev/null || true

  # sudoers drop-in
  if [[ "$sudo_nopasswd" == "1" ]]; then
    chroot "$root_mnt" /bin/bash -lc "echo '${user} ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/010-${user}-nopasswd && chmod 0440 /etc/sudoers.d/010-${user}-nopasswd"
  fi
}

patch_rootfs() {
    local BOOT_DEV="$1"
    local ROOT_DEV="$2"
    local MODE="$3"
    local BOOT_UUID=$(blkid -s PARTUUID -o value "$BOOT_DEV")
    local ROOT_UUID=$(blkid -s PARTUUID -o value "$ROOT_DEV")
    local HOME_DIR=$(getent passwd "${SUDO_USER:-$USER}" | cut -d: -f6)
    local TMP_MOUNT=$(mktemp -d)

    # Patch rootfs partition
    mount "$ROOT_DEV" "$TMP_MOUNT"
    if [[ ! -d "$TMP_MOUNT" ]]; then
        log ERROR "Failed to create temporary mount directory: $TMP_MOUNT"
        exit 1
    fi

    # Create/rename user and set auth
    create_user_in_rootfs "$TMP_MOUNT" "$NEW_USER" "$PASS_HASH" "$EXTRA_GROUPS" "$SUDO_NOPASSWD"

    # SSH setup
    if [[ ! -d "$TMP_MOUNT/home/$NEW_USER/.ssh" ]]; then
        mkdir -p "$TMP_MOUNT/home/$NEW_USER/.ssh"
    fi
    chmod 700 "$TMP_MOUNT/home/$NEW_USER/.ssh"
    chroot "$TMP_MOUNT" chown -R "$NEW_USER:$NEW_USER" "/home/$NEW_USER/.ssh"

	chroot "$TMP_MOUNT" /bin/mkdir -p /etc/ssh/sshd_config.d

	# Ensure the main config includes the drop-in directory (append if missing)
	if ! grep -qE '^\s*Include\s+/etc/ssh/sshd_config\.d/\*\.conf' "$TMP_MOUNT/etc/ssh/sshd_config" 2>/dev/null; then
		echo 'Include /etc/ssh/sshd_config.d/*.conf' >> "$TMP_MOUNT/etc/ssh/sshd_config"
	fi

	# Write cluster override rules for SSH
	cat > "$TMP_MOUNT/etc/ssh/sshd_config.d/99-cluster.conf" <<'EOF'
# Cluster override: allow password/KbdInteractive; disable pubkey auth
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
PasswordAuthentication yes
KbdInteractiveAuthentication yes
EOF
	chroot "$TMP_MOUNT" /bin/chmod 0644 /etc/ssh/sshd_config.d/99-cluster.conf

    # Set hostname
    log INFO "Setting hostname ${HOSTNAME}"
    echo "$HOSTNAME" > "$TMP_MOUNT/etc/hostname"
    if grep -qE '^127\.0\.1\.1' "$TMP_MOUNT/etc/hosts"; then
        sed -i "s/^127\.0\.1\.1.*/127.0.1.1\t$HOSTNAME/g" "$TMP_MOUNT/etc/hosts"
    else
        echo -e "127.0.1.1\t$HOSTNAME" >> "$TMP_MOUNT/etc/hosts"
    fi

    log INFO "Patching /etc/fstab for ${NEW_USER}"
    if [[ $MODE == "local" ]]; then
        tee "$TMP_MOUNT/etc/fstab" > /dev/null <<EOF
PARTUUID=$BOOT_UUID  /boot/firmware vfat    defaults            0       2
PARTUUID=$ROOT_UUID  /              ext4    defaults,noatime    0       1
EOF
    else
        tee "$TMP_MOUNT/etc/fstab" > /dev/null <<EOF
LABEL=system-boot   /boot/firmware  vfat    defaults            0       1
LABEL=writable      /               ext4    defaults            0       1
EOF
    fi

    sync
    umount "$TMP_MOUNT"
    rm -rf "$TMP_MOUNT"
}