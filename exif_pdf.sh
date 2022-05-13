#!/bin/env -S bash
## Update EXIF tags for PDF file.

# Enable for debuging
# set -x

# Verify script requirements
for req in dialog exiftool jq; do
    type ${req} >/dev/null 2>&1 || {
        echo >&2 "$(basename "${0}"): I require ${req} but it's not installed. Aborting."
            exit 1
    }
done && umask 0077

if [[ -z "${1}" ]]; then
    printf "$(basename "${0}"): Please specify a PDF file.\n"
elif [[ "$(file -b --mime-type "${1}")" == "application/pdf" ]]; then
    tags=( Title Subject Author Creator Producer Keywords )

    # get exif tags
    exif="$(jq -r '.[] // null' \
        <(exiftool -j -f "asd" $(for tag in ${tags[@]}; do echo -n "${tag:0:p}-${tag:p} "; done) "${1}" 2> /dev/null) | sed 's/"-"/""/g')"

    # dialog cmd string
    dialog_cmd="dialog --backtitle \"$(basename "${0}"): EXIF Tagger\" --title \"Updating Metadata\" \
        --nocancel --form $(jq '.SourceFile //null' <(echo ${exif})) 0 0 0 \
        $(for key in ${tags[@]}; do
            echo -n "\"${key}\" ${i:-1} 0 $(jq --arg key ${key} '.[$key] //empty' <(echo ${exif})) ${i:-1} 10 49 255 "
            let i=${i:-1}+1
        done)"

    # exif from dialog
    mapfile -t dialog_input< <(bash -c "${dialog_cmd}" 3>&1 1>&2 2>&3)

    # update exif var
    exif_old="${exif}"
    for i in $(seq 0 ${#tags}); do
        exif="$(echo ${exif} |  jq --arg key "${tags[${i}]}" --arg val "${dialog_input[${i}]}" '.[$key] = $val')"
    done

    # modify exif
    if [ "${exif}" != "${exif_old}" ]; then
        exif_file=$(mktemp)
        trap "rm ${exif_file}" EXIT
        echo "${exif}" > "${exif_file}"

        exiftool -overwrite_original -tagsfromfile "${exif_file}" "${1}"
    fi
else
    printf "$(basename "${0}"): PDF file is bad.\n"
fi
