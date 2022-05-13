#!/bin/env -S bash
## Secured bootstrap
## 2021 - Script from www.davideaves.com

# verify requirements
for req in base64 git gpg gzip tput; do
    type ${req} >/dev/null 2>&1 || {
        echo >&2 "$(basename "${0}"): I require ${req} but it's not installed. Aborting."
            exit 1
        }
done && umask 0077

# Get bootstrap file
[[ -f "${1}" ]] && { bootstrap="${1}"; } || {
    bootstrap="${HOME}/.$(basename "${0%.*}")"
}

# Load bootstrap strings
[[ -f "${bootstrap}" ]] && {
    . "${bootstrap}"
} || {
    echo "$(basename "${0}"): Unable to load \"${bootstrap}\"."
}

# Read passphrase
read -sp "Passphrase: " passphrase && echo

# Continue if passphase exists
if [[ -n "${passphrase}" ]]; then
    if [[ "$SHELLOPTS" =~ "xtrace" ]]; then
        ## debug: encrypt strings ##

        # initialize new strs file
        if [[ ! -f "${bootstrap}" ]]; then
            printf "strs=()\n# %s #\n" "$(date)" > "${bootstrap}"
        else
            printf "# %s #\n" "$(date)" >> "${bootstrap}"
        fi

        # read command to encode
        while true; do
            read -p "CMD? " -r CMD

            # generate encrypted/b64 string
            if [[ -n "${CMD}" ]]; then
                printf "strs+=(\'$(gpg --batch --yes --quiet --output - --passphrase "${passphrase}" --symmetric <(echo "${CMD}") | base64 --wrap=0)\')\n"
            else
                break
            fi
        done >> "${bootstrap}"
    elif [[ -n "${strs}" ]]; then
        ## eval: decrypt strings ##

        # decode & run command
        for str in ${strs[*]}; do
            printf "$(tput setaf 5)%s$(tput sgr0)\n" "${str}"
            CMD=`gpg --batch --yes --quiet --passphrase "${passphrase}" --decrypt <(echo "${str}" | base64 --decode) 2> /dev/null`
            if [[ -n "${CMD}" ]]; then
                printf ">>> $(tput setaf 2)%s$(tput sgr0)\n" "${CMD}"
                eval "${CMD}" && unset CMD
            fi
        done
    else
        echo "Nothing to do."
    fi
fi
