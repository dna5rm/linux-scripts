#!/bin/bash
# Handle block devices that use the device-mapper driver.
#
## Requires: sha256sum, dm-mapper, aes modules loaded.

mntDST="$3"; mntSRC="$2"
NAME=`basename "${mntSRC}"`

if [ "$1" == "-m" ]; then

  echo "Mounting ${mntSRC} to ${mntDST}"

  # Generating encryption key.
  printf "Passphrase: "; read -s PASSPH
  KEY=`echo "${PASSPH}" | sha256sum | awk '{print $1}'`

  # Creating mapped device.
  if [ "$(echo ${KEY} | wc -c)" -eq "65" ] && [ ! -b "/dev/mapper/${NAME}" ]; then
    echo 0 `blockdev --getsize "${mntSRC}"` crypt aes-cbc-essiv:sha256 "${KEY}" 0 "${mntSRC}" 0 | dmsetup create ${NAME} > /dev/null 2> /dev/null \
      && echo -e "\n\n/dev/mapper/${NAME}: $(dmsetup status ${NAME})\n" \
      || echo -e "\nError: Unable to create mapping..."

    # Attempting to mount the device.
    if [ -b "/dev/mapper/${NAME}" ]; then
      mount "/dev/mapper/${NAME}" "${mntDST}" > /dev/null 2> /dev/null \
        && df -h "/dev/mapper/${NAME}" \
        || echo "Error: The device failed to mount; your passphrase may have been mistyped or the device may need to be formatted..."
    fi
  fi

elif [ "$1" == "-u" ]; then

  STATUS="Unmounting /dev/mapper/${NAME}: $(dmsetup status ${NAME})"

  # Unmount and remove the block device.
  umount "/dev/mapper/${NAME}" > /dev/null 2> /dev/null
  dmsetup remove "${NAME}" > /dev/null 2> /dev/null \
    && echo "${STATUS}" \
    || echo "Error: No device found or resouce busy..."

else

  printf "Usage: $0 [option]\n\n"
  printf "\t-m <DEVICE> <DESTINATION>\n"
  printf "\t-u <DEVICE>\n\n"

fi
