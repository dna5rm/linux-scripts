## Create/Update SSH key
# Create or Update a new SSH Key for use with future instances.
#
# Ref: https://www.vultr.com/api/

function post_ssh-keys ()
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
    if [[ -z "${vultr_uri}" ]] || [[ -z "${vultr_auth}" ]] || [[ -z "${1}" ]] || [[ -z "${2}" ]]; then
        boxText "$(basename "${0}"):${FUNCNAME[0]} - Create/Update SSH key"
        echo "API Base URI: \${vultr_uri} (${vultr_uri:-missing})
        Auth API Key: \${vultr_auth} (${vultr_auth:-missing})
        SSH User: \${1} (${1:-missing})
        SSH Key: \${2} (${2:-missing})

        Aborting..." | sed 's/%[ \t]*//g'
    else
        # Test if ssh-key is valid.
        [[ ! -z "$(grep -P "^ssh-rsa AAAA[0-9A-Za-z+/]+[=]{0,3}( [^@]+@[^@]+)?" <<< "${2}")" ]] && {

            # Data to post.
            curlData="$(jq --arg user "${1}" --arg key "${2}" '. += {"name": $user, "ssh_key": $key}' <<< "${curlData:-{\}}")"

            curlOutput="$(mktemp)"

            # Get up existing recordId
            recordId="$(get_ssh-keys "${1}" | jq -r '.[].id //empty')"
            [[ ! -z "${recordId}" ]] && {

                # Patch an existing record
                http_code=`curl --silent --location --request PATCH --url "${vultr_uri}/ssh-keys/${recordId}" \
                                --header "Content-Type: application/json" \
                                --header "Authorization: Bearer ${vultr_auth}" \
                                --data "${curlData}" --write-out "%{http_code}" --output "${curlOutput}"`

                # Output data posted
                curlData="$(jq --arg input "${recordId}" '. += {"id": $input}' <<<  "${curlData:-{\}}")"
                jq '.' <<< "${curlData}"

            } || {

                # Post a new record
                http_code=`curl --silent --location --request POST --url "${vultr_uri}/ssh-keys" \
                                --header "Content-Type: application/json" \
                                --header "Authorization: Bearer ${vultr_auth}" \
                                --data "${curlData}" --write-out "%{http_code}" --output "${curlOutput}"`
            }

            # Validate http return code.
            [[ "${http_code}" -gt "204" ]] && {
                echo "$(basename "${0}"):${FUNCNAME[0]} - Bad HTTP response code (${http_code})"
                rm "${curlOutput}"
                return 1
            } || {
                jq '.' "${curlOutput}"
                rm "${curlOutput}"
            }
        }

        # Cleanup Variables.
        unset curlData curlOutput http_code recordId
    fi
}
