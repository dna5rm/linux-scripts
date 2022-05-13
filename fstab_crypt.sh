#!/bin/env bash
## cryptsetup+fstab helper script for root.

# Verify who is running this script.
if [[ ${EUID} -ne 0 ]]; then
     echo "$(basename ${0}): This script must be run as root!"
     exit 1
fi

# Verify script requirements
for req in blkid cryptsetup hwinfo; do
    type ${req} >/dev/null 2>&1 || {
        echo >&2 "$(basename "${0}"): I require ${req} but it's not installed. Aborting."
        exit 1
    }
done && umask 0077 || {
    exit 1
}

function genpasswd ()
{
    local l=$1
    [ "$l" == "" ] && l=20
    tr -dc A-Za-z0-9_ < /dev/urandom | head -c ${l} | xargs
}

if [ -b "${1}" ] && [ -d "${2}" ]; then

    ## Step 1: Generate Key & Format luks
    if [[ "${1: -1}" == [a-z] ]] && [[ -b "${1}" ]] && [[ "$(blkid "${1}" -s TYPE -o value)" != "crypto_LUKS" ]]; then
        blk_model="$(hwinfo --disk --only "${1}" | awk -F'"' '/Model/{print $(NF-1)}')"

        # Generate new key if none exists
        if [ ! -e "${HOME}/crypto_LUKS.key" ]; then
            read -p "Create ${HOME}/crypto_LUKS.key? " -n 1 -r && echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                genpasswd 512 > "${HOME}/crypto_LUKS.key"
            fi
        fi

        # dd+luksFormat block device
        if [ -e "${HOME}/crypto_LUKS.key" ]; then
            read -p "Destroy: ${1} (${blk_model})? " -n 1 -r && echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                dd if=/dev/urandom of="${1}" bs=1M count=2 && echo
                fdisk -l "${1}"
                echo -e "\nluksFormat: ${1}\n"
                cryptsetup --batch-mode luksFormat "${1}" --key-file "${HOME}/crypto_LUKS.key"
            fi
        fi
    fi

    ## Step 2: Generate bin Key for Keyslot1 & backup Header
    if [[ "${1: -1}" == [a-z] ]] && [[ -b "${1}" ]] && [[ "$(blkid "${1}" -s TYPE -o value)" == "crypto_LUKS" ]] && [[ ! -e "/etc/.$(blkid "${1}" -s UUID -o value)" ]]; then
        blk_uuid="$(blkid "${1}" -s UUID -o value)"

        # Open the device with crypto_LUKS.key
        if [ -e "${HOME}/crypto_LUKS.key" ]; then
            echo -e "luksOpen: ${blk_uuid}\n"
            cryptsetup --batch-mode luksOpen "${1}" "${blk_uuid}" --key-file "${HOME}/crypto_LUKS.key"
            cryptsetup status "${blk_uuid}"
        fi

        # Generate system key & add
        if [ -e "${HOME}/crypto_LUKS.key" ]; then
            echo -e "\nBinary key: ${blk_uuid}\n"
            dd if=/dev/urandom of="/etc/.${blk_uuid}" bs=4096 count=1
            echo -e "\nluksAddKey: ${1} ${blk_uuid}\n"
            cryptsetup luksAddKey "${1}" "/etc/.${blk_uuid}" --key-file "${HOME}/crypto_LUKS.key"
            echo -e "luksClose: ${blk_uuid}"
            sync && cryptsetup luksClose "${blk_uuid}"
        fi

        # Display dump for verification
        if [ ! -b "/dev/mapper/${blk_uuid}" ]; then
            cryptsetup luksDump "${1}"
        fi

        # Create a header backup
        if [ ! -e "${HOME}/${blk_uuid}.dump" ]; then
            echo -e "\nluksHeaderBackup: ${HOME}/${blk_uuid}.dump\n"
            cryptsetup luksHeaderBackup "${1}" --header-backup-file "${HOME}/${blk_uuid}.dump"
        fi
    fi

    ## Step 3: Format Device & configure fstab
    if [[ "${1: -1}" == [a-z] ]] && [[ -b "${1}" ]] && [[ "$(blkid "${1}" -s TYPE -o value)" == "crypto_LUKS" ]] && [[ -e "/etc/.$(blkid "${1}" -s UUID -o value)" ]]; then
        blk_uuid="$(blkid "${1}" -s UUID -o value)"

        if [ ! -s "/dev/mapper/${blk_uuid}" ]; then
            echo -e "luksOpen: ${blk_uuid}\n"
            cryptsetup --batch-mode luksOpen "${1}" "${blk_uuid}" --key-file "/etc/.${blk_uuid}"

            # Format the encryptyed file system
            if [ "$(lsblk --noheadings --output FSTYPE --fs "/dev/mapper/${blk_uuid}")" != "ext4" ]; then
                echo -e "mkfs: ${blk_uuid}\n"
                mkfs.ext4 "/dev/mapper/${blk_uuid}"
            else
                echo -e "mkfs: ${blk_uuid} (already formated)"
            fi

            if [ -d "${2}" ]; then

                # Update /etc/crypttab
                if ! grep -q "${blk_uuid}" "/etc/crypttab"; then
                    echo -e "\ncrypttab: ${blk_uuid}"
                    echo "${blk_uuid} UUID=\"${blk_uuid}\" /etc/.${blk_uuid} luks" >> "/etc/crypttab"
                else
                    echo -e "\ncrypttab: ${blk_uuid} (already exists)"
                fi

                # Update /etc/fstab
                if ! grep -q "${blk_uuid}" "/etc/fstab"; then
                    echo -e "\nfstab: ${blk_uuid}"
                    echo "/dev/mapper/${blk_uuid} ${2} ext4 defaults,nofail 0 0" >> "/etc/fstab"
                else
                    echo -e "\nfstab: ${blk_uuid} (already exists)"
                fi

            else
                echo -e "\n$(basename ${0}): no mount point given.."
            fi

            echo -e "\nluksClose: ${blk_uuid}"
            sync && cryptsetup luksClose "${blk_uuid}"
        fi
    fi

elif [ "${1,,}" == "wipe" ] && [ -b "${2}" ]; then
    read -p "Wipe ${2}? " -n 1 -r && echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        dd if=/dev/urandom of="${2}" bs=1M count=2
    fi
else
    echo "$(basename ${0}): block device & mount point required.."
fi
