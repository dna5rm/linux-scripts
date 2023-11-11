# Use OpenSSL to encrypt/decrypt a file using a passphrase.

function crypt () {

    # Use args as user_input.
    local user_input=( "${@}" )

    # Run tests and set func_error any fail.
    if ! type openssl >/dev/null 2>&1; then
        local func_error="openssl executable not found."
    elif ! type shred >/dev/null 2>&1; then
        local func_error="shred executable not found."
    elif [[ "${#user_input[@]}" == "0" ]]; then
        local func_error="Missing files input."
    fi

    # Return if any checks failed.
    [[ ! -z "${func_error}" ]] && {
        [[ "${0}" != -*"bash" ]] && {
            echo >&2 "$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - ${func_error}"
        } || {
            echo >&2 "${FUNCNAME[0]} - ${func_error}"
        }
        return 1
    } || {

        # Set passphrase to element[0] otherwise default to user@host
        [[ ! -f "${user_input[0]}" ]] && {
            local passphrase="${user_input[0]}"
            unset user_input[0]
        } || {
            local passphrase="$(base64 -w0 <(echo "`whoami`@`hostname -f`"))"
        }

        # loop through all files.
        for file in "${user_input[@]}"; do

            # Validate input is a file.
            [[ -f "${file}" ]] && {

                # Encrypt the file.
                [[ "${file##*.}" != "enc" ]] && {
                    openssl enc -aes-256-cbc -e -md sha512 -pbkdf2 -iter 100000 -salt -in "${file}" -k "${passphrase}" -out "${file}.enc" && {
                        shred --force --zero --iterations 3 "${file}" && rm "${file}"
                        printf "[${FUNCNAME[0]}:%s] %s\n" "$(basename "${file}")" "Successfully encrypted!"
                    } || { rm "${file}.enc"; return 1; }

                # Decrypt the file.
                } || {
                    openssl enc -aes-256-cbc -d -md sha512 -pbkdf2 -iter 100000 -salt -in "${file}" -k "${passphrase}" -out "${file%%.enc}" && {
                        shred --force --zero --iterations 3 "${file}" && rm "${file}"
                        printf "[${FUNCNAME[0]}:%s] %s\n" "$(basename "${file}")" "Successfully decrypted!"
                    } || { rm "${file%%.enc}"; return 1; }
                }

            } || {
                printf "[${FUNCNAME[0]}:%s] %s\n" "$(basename "${file}")" "Input is not a file!"
                return 1
            }

        done

    }

}
