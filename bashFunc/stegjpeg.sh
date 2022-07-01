# steghide <STDIN> into an image/jpeg file.

function stegjpeg ()
{
    # Verify function requirements
    for req in file steghide; do
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

    # Read <STDIN> as variable
    stdin="$(cat - &)"

    # Print reference if conditions missing
    if [[ ${?} -eq 0 ]] && [[ -z "${1}" ]]; then
        # Skip basename if shell function
        [[ "${0}" != "-bash" ]] && {
            echo -n "$(basename "${0}"):"
        }
        echo "${FUNCNAME[0]} - steghide <STDIN> into an image/jpeg file."
        echo "Input File: \${1} (${1:-requried})
        Passphrase: \${2} (${2:-optional})
        STDIN: \"${stdin}\"

        Aborting..." | sed 's/^[ \t]*//g'
    else

        # Validate input is a file.
        if [[ -f "${1}" ]] && [[ "$(file --brief --mime-type "${1}")" == "image/jpeg" ]]; then

            # Set passphrase to input if set.
            [[ ! -z "${2}" ]] && {
                passphrase="${2}"
            # Set passphrase to user@hostname.
            } || {
                passphrase="$(base64 -w0 <(echo "`whoami`@`hostname -f`"))"
            }

            # steghide <STDIN> -- embed
            [[ ! -z "${stdin}" ]] && {
                echo "${stdin}" | steghide embed --quiet --passphrase "${passphrase}" --compress 9 --encryption rijndael-256 --coverfile "${1}" --embedfile - --force || {
                    printf "[stegjpeg:%s] %s\n" "$(basename "${1}")" "Something went wrong!"
                    return 1
                }

            # steghide <STDIN> -- extract
            } || {
                steghide extract --quiet --passphrase "${passphrase}" --stegofile "${1}" --extractfile - --force || {
                     printf "[stegjpeg:%s] %s\n" "$(basename "${1}")" "Something went wrong!"
                     return 1
                }
            }

        # Input is not a file.
        else
            printf "[stegjpeg:%s] %s\n" "$(basename "${1}")" "Input not a valid jpeg file!"
            return 1
        fi

    fi
}
