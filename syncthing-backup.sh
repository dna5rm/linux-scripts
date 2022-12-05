#!/bin/env -S bash
## Time Machine-style backups of syncthing targets with rsync

#stpath="/mnt/syncthing"

# Verify script requirements
for req in rsync; do
    type ${req} >/dev/null 2>&1 || {
        echo >&2 "$(basename "${0}"): I require ${req} but it's not installed. Aborting."
        exit 1
    }
done && umask 0077

# Fetch stpath from input or run dir
if [[ -z "${stpath}" && -z "${1}" ]]; then
    stpath="$(pwd "${0}")"
elif [[ -z "${stpath}" && ! -z "${1}" ]]; then
    stpath="${1}"
fi && [[ ! -d "${stpath}" ]] && {
    echo "$(basename "${0}"): \"${stpath:-\$stpath}\" is not a directory or is missing!"
    exit 1;
} || {

    # Build array of targets
    TARGETS=( $(find "${stpath}" -type d -name .stfolder -maxdepth 2 -exec dirname {} \; 2> /dev/null) )

    [[ ${#TARGETS[@]} -ge "1" ]] && {
        for SOURCE in ${TARGETS[@]}; do
            DESTINATION="$(dirname "${SOURCE}")/.ts_$(basename "${SOURCE}")"
            LAST="$(find "${DESTINATION}" -maxdepth 1 -type d -printf "%T@ %p\n" 2> /dev/null | sort -n | awk -F'/.*\..* /' '{gsub(/.* /, "")}END{print $0}')"
            STAMP="$(date "+%s")"

            [[ ! -e "${DESTINATION}" || -z "${LAST}" ]] && {
                # create new timesync backup
                mkdir "${DESTINATION}"
                rsync -avPh --delete --delete-excluded --exclude=".[!.]*" --no-perms "${SOURCE}"/* "${DESTINATION}/${STAMP}" > "${DESTINATION}/$(basename "${0%.*}"_${STAMP})".log 2>&1
            } || {
                # timesync against previous backup
                rsync -avPh --delete --delete-excluded --exclude=".[!.]*" --no-perms --link-dest="${LAST}" "${SOURCE}"/* "${DESTINATION}/${STAMP}" > "${DESTINATION}/$(basename "${0%.*}"_${STAMP})".log 2>&1
            }

        done
    } || {
        echo "$(basename "${0}"): \"${stpath:-\$stpath}\" no syncthing targets found!"
    }
}
