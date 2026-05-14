#!/usr/bin/env bash
# =============================================================================
# phase1-install.sh
# Arch Linux installer for TheOSC dotfiles deployment
# Run from live ISO as root: bash phase1-install.sh
# =============================================================================

set -euo pipefail

# =============================================================================
# COLORS AND FORMATTING
# =============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

info()    { echo -e "${BLUE}[INFO]${RESET}  $*"; }
success() { echo -e "${GREEN}[OK]${RESET}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET}  $*"; }
error()   { echo -e "${RED}[ERROR]${RESET} $*"; exit 1; }
section() { echo -e "\n${BOLD}${CYAN}=== $* ===${RESET}\n"; }

confirm() {
    # confirm "Question" → returns 0 for yes, 1 for no
    local prompt="$1"
    local response
    while true; do
        read -rp "$(echo -e "${YELLOW}${prompt} [y/n]: ${RESET}")" response
        case "$response" in
            [yY]) return 0 ;;
            [nN]) return 1 ;;
            *) echo "Please answer y or n." ;;
        esac
    done
}

prompt() {
    # prompt "Question" "default_value" → stores in REPLY
    local question="$1"
    local default="$2"
    read -rp "$(echo -e "${CYAN}${question}${RESET} [${default}]: ")" REPLY
    REPLY="${REPLY:-$default}"
}

prompt_password() {
    # prompt_password "Label" → stores in PASSWORD
    local label="$1"
    local pass1 pass2
    while true; do
        read -srp "$(echo -e "${CYAN}${label}: ${RESET}")" pass1
        echo
        read -srp "$(echo -e "${CYAN}Confirm ${label}: ${RESET}")" pass2
        echo
        if [[ "$pass1" == "$pass2" ]]; then
            PASSWORD="$pass1"
            return 0
        fi
        warn "Passwords do not match, try again."
    done
}

# =============================================================================
# SAFETY CHECKS
# =============================================================================

section "Pre-flight Checks"

# Must be root
if [[ $EUID -ne 0 ]]; then
    error "This script must be run as root. Try: sudo bash phase1-install.sh"
fi
success "Running as root"

# Must be booted from Arch ISO
if ! grep -q "archiso" /proc/cmdline 2>/dev/null; then
    warn "This does not appear to be an Arch live ISO environment."
    if ! confirm "Continue anyway? (not recommended)"; then
        error "Aborted."
    fi
else
    success "Running from Arch ISO"
fi

# Must have UEFI
if [[ ! -d /sys/firmware/efi ]]; then
    error "No UEFI detected. This installer requires UEFI boot mode."
fi
success "UEFI detected"

# Check internet
info "Checking internet connectivity..."
if ! ping -c 1 -W 5 archlinux.org &>/dev/null; then
    error "No internet connection detected. Connect first then re-run.\nHint: use 'iwctl' for WiFi or check your ethernet cable."
fi
success "Internet connection detected"

# =============================================================================
# GATHER INSTALLATION PARAMETERS
# =============================================================================

section "Installation Parameters"
info "All questions will be asked now. Nothing will be written to disk until you confirm."
echo

# -----------------------------------------------------------------------------
# DISK SELECTION
# -----------------------------------------------------------------------------
echo -e "${BOLD}Available disks:${RESET}"
echo
lsblk -d -o NAME,SIZE,MODEL,TYPE | grep disk
echo

info "Enter the target disk (e.g. sda, nvme0n1 — do NOT include /dev/)"
prompt "Target disk" "nvme0n1"
TARGET_DISK="/dev/${REPLY}"

# Verify disk exists
if [[ ! -b "$TARGET_DISK" ]]; then
    error "Disk ${TARGET_DISK} not found."
fi
success "Target disk: ${TARGET_DISK}"

# -----------------------------------------------------------------------------
# PARTITION LAYOUT PREVIEW
# -----------------------------------------------------------------------------
echo
info "The following partition layout will be created on ${TARGET_DISK}:"
echo -e "  ${CYAN}Partition 1${RESET} — EFI  — 1GB   — FAT32"
echo -e "  ${CYAN}Partition 2${RESET} — ROOT — REST  — btrfs"
echo
info "btrfs subvolumes:"
echo -e "  ${CYAN}@${RESET}          → /"
echo -e "  ${CYAN}@home${RESET}      → /home"
echo -e "  ${CYAN}@snapshots${RESET} → /.snapshots"
echo -e "  ${CYAN}@var_log${RESET}   → /var/log"
echo

# -----------------------------------------------------------------------------
# ENCRYPTION
# -----------------------------------------------------------------------------
ENCRYPT=false
if confirm "Enable full disk encryption (LUKS2)? Recommended for a laptop"; then
    ENCRYPT=true
    success "Encryption enabled"
    prompt_password "Encryption passphrase"
    LUKS_PASSWORD="$PASSWORD"
else
    warn "Encryption disabled"
fi

# -----------------------------------------------------------------------------
# HOSTNAME
# -----------------------------------------------------------------------------
echo
prompt "Hostname" "archlinux"
HOSTNAME="$REPLY"
success "Hostname: ${HOSTNAME}"

# -----------------------------------------------------------------------------
# USERNAME
# -----------------------------------------------------------------------------
prompt "Username" "max"
USERNAME="$REPLY"
success "Username: ${USERNAME}"

# -----------------------------------------------------------------------------
# PASSWORDS
# -----------------------------------------------------------------------------
echo
info "Set password for user: ${USERNAME}"
prompt_password "User password"
USER_PASSWORD="$PASSWORD"

echo
info "Set root password"
prompt_password "Root password"
ROOT_PASSWORD="$PASSWORD"

# -----------------------------------------------------------------------------
# TIMEZONE
# -----------------------------------------------------------------------------
echo
info "Timezone selection"
info "Common examples: America/Chicago, America/New_York, America/Los_Angeles, Europe/London"
prompt "Timezone" "America/Chicago"
TIMEZONE="$REPLY"

# Verify timezone exists
if [[ ! -f "/usr/share/zoneinfo/${TIMEZONE}" ]]; then
    warn "Timezone '${TIMEZONE}' not found in zoneinfo database."
    warn "You can find valid timezones by browsing /usr/share/zoneinfo/"
    if ! confirm "Continue with this timezone anyway?"; then
        error "Aborted. Re-run and enter a valid timezone."
    fi
fi
success "Timezone: ${TIMEZONE}"

# -----------------------------------------------------------------------------
# LOCALE
# -----------------------------------------------------------------------------
prompt "Locale" "en_US.UTF-8"
LOCALE="$REPLY"
success "Locale: ${LOCALE}"

# -----------------------------------------------------------------------------
# DOTFILES REPO
# -----------------------------------------------------------------------------
echo
prompt "Dotfiles repo URL" "git@github.com:TheOSC/dotfiles.git"
DOTFILES_REPO="$REPLY"
success "Dotfiles repo: ${DOTFILES_REPO}"

# -----------------------------------------------------------------------------
# SUMMARY AND FINAL CONFIRMATION
# -----------------------------------------------------------------------------
section "Installation Summary"
echo -e "  ${BOLD}Disk:${RESET}        ${TARGET_DISK}"
echo -e "  ${BOLD}Encryption:${RESET}  ${ENCRYPT}"
echo -e "  ${BOLD}Hostname:${RESET}    ${HOSTNAME}"
echo -e "  ${BOLD}Username:${RESET}    ${USERNAME}"
echo -e "  ${BOLD}Timezone:${RESET}    ${TIMEZONE}"
echo -e "  ${BOLD}Locale:${RESET}      ${LOCALE}"
echo -e "  ${BOLD}Dotfiles:${RESET}    ${DOTFILES_REPO}"
echo
echo -e "${RED}${BOLD}WARNING: All data on ${TARGET_DISK} will be permanently destroyed.${RESET}"
echo -e "${RED}${BOLD}This cannot be undone.${RESET}"
echo
if ! confirm "Proceed with installation?"; then
    error "Aborted. No changes were made."
fi

# =============================================================================
# PARTITIONING AND FORMATTING
# =============================================================================

section "Partitioning ${TARGET_DISK}"

# Wipe existing partition table
info "Wiping existing partition table..."
sgdisk --zap-all "$TARGET_DISK" &>/dev/null
success "Partition table wiped"

# Create new GPT partition table
# Partition 1: EFI  - 1GB
# Partition 2: ROOT - remainder
info "Creating partitions..."
sgdisk \
    --new=1:0:+1G     --typecode=1:ef00 --change-name=1:"EFI" \
    --new=2:0:0       --typecode=2:8300 --change-name=2:"ROOT" \
    "$TARGET_DISK" &>/dev/null
success "Partitions created"

# Settle partition table
partprobe "$TARGET_DISK"
sleep 2

# Determine partition naming convention
# nvme drives use p1/p2, sata/scsi use 1/2
if [[ "$TARGET_DISK" == *"nvme"* ]] || [[ "$TARGET_DISK" == *"mmcblk"* ]]; then
    EFI_PART="${TARGET_DISK}p1"
    ROOT_PART="${TARGET_DISK}p2"
else
    EFI_PART="${TARGET_DISK}1"
    ROOT_PART="${TARGET_DISK}2"
fi

success "EFI partition:  ${EFI_PART}"
success "Root partition: ${ROOT_PART}"

# =============================================================================
# ENCRYPTION (CONDITIONAL)
# =============================================================================

if [[ "$ENCRYPT" == true ]]; then
    section "Setting Up Encryption"

    info "Formatting LUKS2 container on ${ROOT_PART}..."
    echo -n "$LUKS_PASSWORD" | cryptsetup luksFormat \
        --type luks2 \
        --cipher aes-xts-plain64 \
        --key-size 512 \
        --hash sha512 \
        --pbkdf argon2id \
        "${ROOT_PART}" -
    success "LUKS2 container created"

    info "Opening LUKS container..."
    echo -n "$LUKS_PASSWORD" | cryptsetup open "${ROOT_PART}" cryptroot -
    success "LUKS container opened at /dev/mapper/cryptroot"

    BTRFS_DEVICE="/dev/mapper/cryptroot"
else
    BTRFS_DEVICE="$ROOT_PART"
fi

# =============================================================================
# FORMATTING
# =============================================================================

section "Formatting Partitions"

info "Formatting EFI partition as FAT32..."
mkfs.fat -F32 -n EFI "$EFI_PART" &>/dev/null
success "EFI partition formatted"

info "Formatting root partition as btrfs..."
mkfs.btrfs -f -L ROOT "$BTRFS_DEVICE" &>/dev/null
success "Root partition formatted"

# =============================================================================
# BTRFS SUBVOLUMES
# =============================================================================

section "Creating btrfs Subvolumes"

# Mount root temporarily to create subvolumes
mount "$BTRFS_DEVICE" /mnt

info "Creating subvolumes..."
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@var_log
success "Subvolumes created"

# Unmount before remounting with options
umount /mnt

# =============================================================================
# MOUNTING
# =============================================================================

section "Mounting Filesystems"

# Mount options for btrfs
BTRFS_OPTS="noatime,compress=zstd,space_cache=v2"

info "Mounting subvolumes..."
mount -o "${BTRFS_OPTS},subvol=@"          "$BTRFS_DEVICE" /mnt
mkdir -p /mnt/{home,.snapshots,var/log,boot}
mount -o "${BTRFS_OPTS},subvol=@home"      "$BTRFS_DEVICE" /mnt/home
mount -o "${BTRFS_OPTS},subvol=@snapshots" "$BTRFS_DEVICE" /mnt/.snapshots
mount -o "${BTRFS_OPTS},subvol=@var_log"   "$BTRFS_DEVICE" /mnt/var/log
mount "$EFI_PART" /mnt/boot
success "All filesystems mounted"

info "Verifying mount layout..."
findmnt --real | grep /mnt
echo

# =============================================================================
# BASE SYSTEM INSTALLATION
# =============================================================================

section "Installing Base System"

info "Updating pacman mirrorlist..."
reflector --country US --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
success "Mirrorlist updated"

info "Installing base system via pacstrap..."
info "This will take a few minutes depending on your connection..."
pacstrap -K /mnt \
    base \
    base-devel \
    linux \
    linux-firmware \
    linux-headers \
    btrfs-progs \
    networkmanager \
    openssh \
    git \
    vim \
    sudo \
    zsh \
    reflector \
    cryptsetup \
    sbctl
success "Base system installed"

# =============================================================================
# FSTAB
# =============================================================================

section "Generating fstab"
genfstab -U /mnt >> /mnt/etc/fstab
success "fstab generated"

info "fstab contents:"
cat /mnt/etc/fstab

# =============================================================================
# COPY SCRIPTS INTO NEW SYSTEM
# =============================================================================

section "Preparing Chroot Environment"

info "Copying install scripts into new system..."
mkdir -p /mnt/root/install
cp "$(realpath "$0")" /mnt/root/install/phase1-install.sh

# Write all collected variables to a file the chroot can read
cat > /mnt/root/install/install.env << EOF
HOSTNAME="${HOSTNAME}"
USERNAME="${USERNAME}"
USER_PASSWORD="${USER_PASSWORD}"
ROOT_PASSWORD="${ROOT_PASSWORD}"
TIMEZONE="${TIMEZONE}"
LOCALE="${LOCALE}"
DOTFILES_REPO="${DOTFILES_REPO}"
ENCRYPT=${ENCRYPT}
ROOT_PART="${ROOT_PART}"
EOF
chmod 600 /mnt/root/install/install.env
success "Scripts and variables staged in new system"

# =============================================================================
# CHROOT CONFIGURATION
# =============================================================================

section "Configuring System via Chroot"

arch-chroot /mnt /bin/bash << 'CHROOT'

# Load variables collected before chroot
source /root/install/install.env

# Colors still work inside chroot
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'
success() { echo -e "${GREEN}[OK]${RESET}    $*"; }
info()    { echo -e "\033[0;34m[INFO]${RESET}  $*"; }
section() { echo -e "\n${BOLD}${CYAN}=== $* ===${RESET}\n"; }

# -----------------------------------------------------------------------------
# TIMEZONE
# -----------------------------------------------------------------------------
section "Timezone"
ln -sf "/usr/share/zoneinfo/${TIMEZONE}" /etc/localtime
hwclock --systohc
success "Timezone set to ${TIMEZONE}"

# -----------------------------------------------------------------------------
# LOCALE
# -----------------------------------------------------------------------------
section "Locale"
sed -i "s/^#${LOCALE}/${LOCALE}/" /etc/locale.gen
locale-gen
echo "LANG=${LOCALE}" > /etc/locale.conf
success "Locale set to ${LOCALE}"

# -----------------------------------------------------------------------------
# HOSTNAME
# -----------------------------------------------------------------------------
section "Hostname"
echo "$HOSTNAME" > /etc/hostname
cat > /etc/hosts << EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   ${HOSTNAME}.localdomain ${HOSTNAME}
EOF
success "Hostname set to ${HOSTNAME}"

# -----------------------------------------------------------------------------
# USERS AND PASSWORDS
# -----------------------------------------------------------------------------
section "Users"

# Set root password
echo "root:${ROOT_PASSWORD}" | chpasswd
success "Root password set"

# Create user with zsh as default shell
useradd -m -G wheel -s /bin/zsh "$USERNAME"
echo "${USERNAME}:${USER_PASSWORD}" | chpasswd
success "User ${USERNAME} created with zsh shell"

# Enable wheel group sudo access
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
success "Sudo enabled for wheel group"

# Disable root SSH login
sed -i 's/^#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
echo "PermitRootLogin no" >> /etc/ssh/sshd_config
success "Root SSH login disabled"

# -----------------------------------------------------------------------------
# INITRAMFS
# -----------------------------------------------------------------------------
section "Initramfs"

if [[ "$ENCRYPT" == true ]]; then
    info "Adding encryption hooks to mkinitcpio..."
    sed -i 's/^HOOKS=.*/HOOKS=(base udev autodetect microcode modconf kms keyboard keymap consolefont block encrypt filesystems fsck)/' /etc/mkinitcpio.conf
else
    sed -i 's/^HOOKS=.*/HOOKS=(base udev autodetect microcode modconf kms keyboard keymap consolefont block filesystems fsck)/' /etc/mkinitcpio.conf
fi

mkinitcpio -P
success "Initramfs generated"

# -----------------------------------------------------------------------------
# BOOTLOADER
# -----------------------------------------------------------------------------
section "Bootloader"

bootctl install
success "systemd-boot installed"

# Get UUID of root partition for bootloader entry
if [[ "$ENCRYPT" == true ]]; then
    ROOT_UUID=$(blkid -s UUID -o value "${ROOT_PART}")
    KERNEL_PARAMS="rd.luks.name=${ROOT_UUID}=cryptroot root=/dev/mapper/cryptroot rootflags=subvol=@ rw quiet"
else
    ROOT_UUID=$(blkid -s UUID -o value "${ROOT_PART}")
    KERNEL_PARAMS="root=UUID=${ROOT_UUID} rootflags=subvol=@ rw quiet"
fi

# Boot loader configuration
cat > /boot/loader/loader.conf << EOF
default arch.conf
timeout 3
console-mode max
editor no
EOF

# Boot entry
cat > /boot/loader/entries/arch.conf << EOF
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options ${KERNEL_PARAMS}
EOF

# Fallback entry
cat > /boot/loader/entries/arch-fallback.conf << EOF
title   Arch Linux (fallback)
linux   /vmlinuz-linux
initrd  /initramfs-linux-fallback.img
options ${KERNEL_PARAMS}
EOF

success "Boot entries created"

# -----------------------------------------------------------------------------
# SERVICES
# -----------------------------------------------------------------------------
section "Enabling Services"

systemctl enable NetworkManager
success "NetworkManager enabled"

systemctl enable sshd
success "sshd enabled"

systemctl enable reflector.timer
success "reflector.timer enabled (weekly mirror updates)"

# -----------------------------------------------------------------------------
# PHASE 2 PREPARATION
# -----------------------------------------------------------------------------
section "Phase 2 Preparation"

# Create phase2 trigger script in new user's home
mkdir -p /home/${USERNAME}
cat > /home/${USERNAME}/start-phase2.sh << EOF
#!/usr/bin/env bash
# Run this after first boot to complete environment setup
# git clone your dotfiles repo first, then run phase2-bootstrap.sh
echo "Welcome to your new Arch install."
echo "Next step: run phase2-bootstrap.sh from your dotfiles repo"
echo "  git clone ${DOTFILES_REPO} ~/dotfiles"
echo "  bash ~/dotfiles/install/phase2-bootstrap.sh"
EOF
chmod +x /home/${USERNAME}/start-phase2.sh
chown ${USERNAME}:${USERNAME} /home/${USERNAME}/start-phase2.sh

# Leave a flag that phase1 completed successfully
touch /home/${USERNAME}/.phase1-complete
chown ${USERNAME}:${USERNAME} /home/${USERNAME}/.phase1-complete

success "Phase 2 preparation complete"

# -----------------------------------------------------------------------------
# CLEANUP
# -----------------------------------------------------------------------------
section "Cleaning Up"

# Remove install env file (contains passwords)
rm -f /root/install/install.env
success "Credentials cleaned from disk"

echo
echo -e "${GREEN}${BOLD}Chroot configuration complete.${RESET}"

CHROOT

# =============================================================================
# UNMOUNT AND REBOOT
# =============================================================================

section "Finalizing"

info "Unmounting filesystems..."
umount -R /mnt
success "Filesystems unmounted"

if [[ "$ENCRYPT" == true ]]; then
    cryptsetup close cryptroot
    success "LUKS container closed"
fi

echo
echo -e "${GREEN}${BOLD}╔════════════════════════════════════════╗${RESET}"
echo -e "${GREEN}${BOLD}║   Installation complete!               ║${RESET}"
echo -e "${GREEN}${BOLD}║                                        ║${RESET}"
echo -e "${GREEN}${BOLD}║   Remove install media and reboot.     ║${RESET}"
echo -e "${GREEN}${BOLD}║   Then run start-phase2.sh             ║${RESET}"
echo -e "${GREEN}${BOLD}╚════════════════════════════════════════╝${RESET}"
echo
if confirm "Reboot now?"; then
    reboot
fi
