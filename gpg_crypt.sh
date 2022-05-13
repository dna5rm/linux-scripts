#!/bin/env -S bash
## GnuPG encryption/decryption helper.
## 2021 - Script from www.davideaves.com

export GPG_TTY=$(tty)

# Verify script requirements
for req in curl gpg jq; do
    type ${req} >/dev/null 2>&1 || {
        echo >&2 "$(basename "${0}"): I require ${req} but it's not installed. Aborting."
        exit 1
    }
done && umask 0077

# Fetch existing keys
keyid=( `gpg --list-keys --keyid-format 0xLONG | awk '/^sub.*[E]/{gsub("[]|[]|/", " "); print $3,$NF}'` )

# Help manage keys
if [ -z "${keyid}" ] && [ -z "${gpg_method}" ]; then
    [ -f "${HOME}/bin/rc_files/gpg.conf" -a ! -f "${HOME}/.gnupg/gpg.conf" ] && {
        cat "${HOME}/bin/rc_files/gpg.conf" > "${HOME}/.gnupg/gpg.conf"
    }

    # Generate a new keys
    read -p "(G)enerate new or (R)estore keys? (g/r) " -n 1 -r; echo
        if [[ "${REPLY}" =~ ^[Gg]$ ]]; then
            gpg --full-generate-key || gpg --gen-key

            # Backup keys
            read -p "Export a backup of keys? " -n 1 -r; echo
            if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
                gpg --armor --export-secret-key > "${HOME}/gpg_secret-key.asc"
                gpg --armor --export-secret-subkeys > "${HOME}/gpg_secret-subkeys.asc"
                gpg --armor --export > "${HOME}/gpg_public-key.asc"
                gpg --armor --export-ownertrust > "${HOME}/gpg_ownertrust.txt"
            fi

        # Restore existing keys
        elif [[ "${REPLY}" =~ ^[Rr]$ ]]; then
            for asc in ${HOME}/gpg_*.asc; do
                gpg --import "${asc}"
            done && gpg --import-ownertrust "${HOME}/gpg_ownertrust.txt"
        fi && unset ${REPLY}

elif [ -n "${gpg_method}" ]; then
    unset keyid
fi

# Exit if no user input or not debugging.
if [[ ! "$SHELLOPTS" =~ "xtrace" ]] && [[ -z "${@}" ]]; then
    echo "$(basename "${0}"): GnuPG encryption/decryption helper."
    echo "File or Directory input is required to continue!"
    exit 0
fi

# Create debug test file
if [[ "$SHELLOPTS" =~ "xtrace" ]] && [[ -z "${@}" ]]; then
    debug_b64="/9j/4AAQSkZJRgABAQAAZABkAAD/2wCEABQQEBkSGScXFycyJh8mMi4mJiYmLj41NTU1NT5EQUFBQUFBREREREREREREREREREREREREREREREREREREREQBFRkZIBwgJhgYJjYmICY2RDYrKzZERERCNUJERERERERERERERERERERERERERERERERERERERERERERERERERP/AABEIAAEAAQMBIgACEQEDEQH/xABMAAEBAAAAAAAAAAAAAAAAAAAABQEBAQAAAAAAAAAAAAAAAAAABQYQAQAAAAAAAAAAAAAAAAAAAAARAQAAAAAAAAAAAAAAAAAAAAD/2gAMAwEAAhEDEQA/AJQA9Yv/2Q=="

    # Create temp file
    if debug_file="$(mktemp)"; then
        trap "{ if [ -e "${debug_file}*" ]; then rm -rf "${debug_file}*"; fi }" SIGINT SIGTERM ERR EXIT
    else
        echo "Failure, exit status: ${?}"
        exit ${?}
    fi && echo -n "${debug_b64}" | base64 -d > "${debug_file}"

    MimeDB=( "https://raw.githubusercontent.com/jshttp/mime-db/master/db.json" "${HOME}/.cache/mime.json" )
    [ ! -s "${MimeDB[1]}" ] && {
        curl -s "${MimeDB[0]}" | jq > "${MimeDB[1]}"
    }

    debug_mime="$(file -b --mime-type "${debug_file}")"
    debug_hash="$(sha1sum "${debug_temp}" | awk '{print $1}')"
    debug_ext="$(jq -r --arg MIME "${debug_mime}" '.[$MIME].extensions[0] // empty' "${MimeDB[1]}")"
    debug_output="${debug_hash}.${debug_ext}"

    mv "${debug_file}" "${debug_file}.${debug_ext}"
    set -- "$@" "${debug_file}.${debug_ext}"
    file "${debug_file}.${debug_ext}"
fi

### BEGIN ###
for input in "${@}"; do

    file_ext="$(basename "${input##*.}")"

    ## symmetric encryption: file ##
    if [ -z "${keyid[0]}" ] && [ -f "${input}" ]; then
        if [ "${file_ext}" != "gpg" ]; then
            gpg --batch --yes --quiet --output "$(basename "${input:-'null'}").gpg" --symmetric "${input}"
        ## decrypt file ##
        elif [[ "${input%.*}" =~ ".tgz"$ ]]; then
            gpg --batch --yes --quiet --decrypt "${input}" | tar xzfv -
        else
            gpg --batch --yes --quiet --output "$(basename "${input%.*}")" --decrypt "${input}"
        fi

    ## symmetric encryption: directory ##
    elif [ -z "${keyid[0]}" ] && [ -d "${input}" ]; then
        tar czfv - "${input}" | gpg --batch --yes --quiet --output "$(basename "${input:-'null'}").tgz.gpg" --symmetric

    ## key encryption: file ##
    elif [ -n "${keyid[0]}" ] && [ -f "${input}" ]; then
        if [ "${file_ext}" != "gpg" ]; then
            gpg --batch --yes --quiet --output "$(basename "${input:-'null'}").gpg" --recipient ${keyid[0]} --encrypt "${input}"

        ## decrypt file ##
        elif [[ "${input%.*}" =~ ".tgz"$ ]]; then
            gpg --batch --yes --quiet --recipient ${keyid[0]} --decrypt "${input}" | tar xzfv -
        else
            gpg --batch --yes --quiet --output "$(basename "${input%.*}")" --recipient ${keyid[0]} --decrypt "${input}"
        fi

    ## key encryption: directory ##
    elif [ -n "${keyid[0]}" ] && [ -d "${input}" ]; then
        tar czfv - "${input}" | gpg --batch --yes --quiet --recipient ${keyid[0]} --encrypt > "$(basename "${input:-'null'}").tgz.gpg"
    fi

done
### FINISH ###
