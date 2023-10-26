# Get self GeoIP info

function selfGeoIP ()
{
    # Verify function requirements
    for req in box_text curl; do
        type ${req} >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}"):${FUNCNAME[0]} - cmd/function \"${req}\" is required!"
            exit 1
        }
    done

    # Print reference if conditions missing.
    if [[ -z "${crc1net_auth}" ]]; then
        box_text "$(basename "${0}"):${FUNCNAME[0]} - Get self GeoIP info."
	    echo "User Auth: \${crc1net_auth} (${crc1net_auth:-missing})
        IPv4 Resolve: \${1} (${1:-false})

        Aborting..." | sed 's/^[ \t]*//g'
        exit 1
    else
        [[ -z ${1} ]] && {
            curl --silent --ipv6 --user "${crc1net_auth}" --location --url "https://root.crc1.net"
        } || {
            curl --silent --ipv4 --user "${crc1net_auth}" --location --url "https://root.crc1.net"
        }
    fi
}
