#!/bin/env bash
## fdupes output to json

# Enable for debuging
# set -x

# Verify script requirements
for req in fdupes jq openssl sponge; do
    type ${req} >/dev/null 2>&1 || {
        echo >&2 "$(basename "${0}"): I require ${req} but it's not installed. Aborting."
        exit 1
    }
done && umask 0077

# Exit if no debug or user input
if [[ ! "$SHELLOPTS" =~ "xtrace" ]] && [[ -z "${1}" ]]; then
    echo "$(basename "${0}"): fdupes output to json."
    echo "Directory input is required to continue!"
    exit 0
fi

# Create debug files.
if [[ "$SHELLOPTS" =~ "xtrace" ]] && [[ -z "${1}" ]]; then
    echo "Running in debug mode!"

    # Create test files.
    for i in {a..z}; do
        echo "$(seq -f "_test ${i}%02g.txt" 5)" | while read file; do
            echo "Creating test file: ${file}"
            openssl rand -base64 1200 > "${file}"
        done
    done

    # Randomly shuffle files totest directories.
    for i in {1..3}; do
        for file in _test*.txt; do
            echo "Pass [${i}] Duplicating: ${file}"
            install -m 644 -D "${file}" -t "$(shuf -e -n 1 "_dupe one" "_dupe two" "_dupe three" "_dupe four" "_dupe five")"
        done && [ "${i}" == "3" ] && { rm _test*.txt; }
    done
fi

# Create temp file
if _fdupes="$(mktemp)"; then
    echo "[]" > "${_fdupes}"
    trap "{ rm -rf "${_fdupes}*"; }" SIGINT SIGTERM ERR EXIT
else
    echo "Failure, exit status: ${?}"
    exit ${?}
fi

### BEGIN ###

if [[ ! -z "{1}" ]]; then
    >&2 echo -e "Running & saving output: fdupes.txt"
    fdupes --quiet --recurse "${1}" > "fdupes.txt"

    >&2 echo -e "Parsing output to JSON: fdupes.json"
    cat "fdupes.txt" | while read dupe; do

        if [[ "${dupe}" == "" ]]; then

            # Increment the dupe itteration.
            [[ "${_fdupes:-null}" != "null" ]] && {
                let i++
                unset md5 type
            }

        else

            # Create the MD5 & TYPE key.
            if [[ "${md5:-null}" == "null" ]]; then
                md5="$(md5sum "${dupe}" | awk '{print $1}')" && >&2 echo -n "${md5:-null} "
                type="$(file "${dupe}" | sed 's/^.*: //')" && >&2 echo "< ${type:-null}"

                # Create itteration for new dupe.
                jq -c --arg inc "${i:-0}" --arg file "${dupe}" --arg md5 "${md5}" --arg type "${type}" '.[$inc|fromjson] += {"md5": $md5, "type": $type}' "${_fdupes}" | sponge "${_fdupes}"
            fi

            # Update the file list.
            jq -c --arg inc "${i:-0}" --arg file "${dupe}" --arg md5 "${md5}" '.[$inc|fromjson].files += [$file]' "${_fdupes}" | sponge "${_fdupes}"
        fi
    done && jq '.' "${_fdupes}" > "fdupes.json"
fi

### FINISH ###
