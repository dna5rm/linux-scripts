## Get Account Info
# Get your Vultr account, permission, and billing information.
#
# Ref: https://www.vultr.com/api/

function get_account ()
{
    # Verify function requirements
    for req in boxText curl; do
        type ${req} >/dev/null 2>&1 || {
            [[ "${0}" != "-bash" ]] && {
                echo >&2 "$(basename "${0}"):${FUNCNAME[0]} - cmd/function \"${req}\" is required!"
            } || {
                echo >&2 "${FUNCNAME[0]} - cmd/function \"${req}\" is required!"
            }
            return 1
        }
    done

    # Print reference if conditions missing.
    if [[ -z "${vultr_uri}" ]] || [[ -z "${vultr_auth}" ]]; then
        boxText "$(basename "${0}"):${FUNCNAME[0]} - Get Account Info"
        echo "API Base URI: \${vultr_uri} (${vultr_uri:-missing})
        Auth API Key: \${vultr_auth} (${vultr_auth:-missing})

        Aborting..." | sed 's/^[ \t]*//g'
    else
        curlOutput="$(mktemp)"
        http_code=`curl --silent --location --request GET --url "${vultr_uri}/account" \
                        --header "Content-Type: application/json" \
                        --header "Authorization: Bearer ${vultr_auth}" \
                        --write-out "%{http_code}" --output "${curlOutput}"`

        # Validate http return code.
        [[ "${http_code}" != "200" ]] && {
            echo "$(basename "${0}"):${FUNCNAME[0]} - Bad HTTP response code (${http_code})"
            rm "${curlOutput}"
            return 1
        } || {
            jq '.account' "${curlOutput}"
            rm "${curlOutput}"
        }

        # Cleanup Variables.
        unset curlOutput http_code
    fi
}
