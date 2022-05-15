# Use OpenSSL to encrypt/decrypt a file.

function crypt ()
{
    # Verify function requirements
    for req in openssl shred; do
        type ${req} >/dev/null 2>&1 || {
            # Skip basename if shell function
            [[ "${0}" != "-bash" ]] && {
                echo >&2 "$(basename "${0}"):${FUNCNAME[0]} - cmd/function \"${req}\" is required!"
            } || {
                echo >&2 "${FUNCNAME[0]} - cmd/function \"${req}\" is required!"
           }
            return 1
        }
    done

    # Print reference if conditions missing
    if [[ ${?} -eq 0 ]] && [[ -z "${1}" ]]; then
        # Skip basename if shell function
        [[ "${?}" -ne 0 ]] && {
            echo -n "$(basename "${0}"):"
        }
        echo "${FUNCNAME[0]} - Encrypt/Decrypt a file."
        echo "Input File: \${1} (${1:-requried})
        Passphrase: \${2} (${2:-optional})

        Aborting..." | sed 's/^[ \t]*//g'
    else

        # Validate input is a file.
        [[ -f "${1}" ]] && {

            # Set passphrase to input if set.
            [[ ! -z "${2}" ]] && {
                passphrase="${2}"
            # Set passphrase to user@hostname.
            } || {
                passphrase="$(base64 -w0 <(echo "`whoami`@`hostname -f`"))"
            }

            # Encrypt the file.
            [[ "${1##*.}" != "enc" ]] && {
                openssl enc -aes-256-cbc -e -md sha512 -pbkdf2 -iter 100000 -salt -in "${1}" -k "${2:-pass}" -out "${1}.enc" && {
                    shred --force --zero --iterations 3 "${1}" && rm "${1}"
                    printf "[crypt:%s] %s\n" "$(basename "${1}")" "Successfully encrypted!"
                } || {
                    rm "${1}.enc"
                    printf "[crypt:%s] %s\n" "$(basename "${1}")" "Something went wrong!"
                    return 1
                }

            # Decrypt the file.
            } || {
                openssl enc -aes-256-cbc -d -md sha512 -pbkdf2 -iter 100000 -salt -in "${1}" -k "${2:-pass}" -out "${1%%.enc}" && {
                    shred --force --zero --iterations 3 "${1}" && rm "${1}"
                    printf "[crypt:%s] %s\n" "$(basename "${1}")" "Successfully decrypted!"
                } || {
                    rm "${1%%.enc}"
                    printf "[crypt:%s] %s\n" "$(basename "${1}")" "Something went wrong!";
                    return 1
                }
            }

        # Input is not a file.
        } || {
            printf "[crypt:%s] %s\n" "$(basename "${1}")" "Input not a file!"
            return 1
        }

    fi
}
