## Create/Update Record
# Create or Update a DNS record
#
# Ref: https://www.vultr.com/api/

function post_domains_records ()
{
    # Verify function requirements
    for req in boxText curl get_domains; do
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
        boxText "$(basename "${0}"):${FUNCNAME[0]} - Create/Update DNS Record"
        echo "API Base URI: \${vultr_uri} (${vultr_uri:-missing})
        Auth API Key: \${vultr_auth} (${vultr_auth:-missing})
        FQDN: \${1} (${1:-missing})
        Address: \${2} (${2:-missing})

        Aborting..." | sed 's/^[ \t]*//g'
    else
        # Test user input for domain & append the record id.
        [[ ! -z "$(echo "${1}" | grep -P '(?=^.{1,254}$)(^(?>(?!\d+\.)[a-zA-Z0-9_\-]{1,63}\.?)+(?:[a-zA-Z]{2,})$)')" ]] && {

            # Validate domain exists, if not will be null.
            postDomain="/domains/$(get_domains "${1#*.}" | jq -r '.[].domain')/records"

            # Start to form data to post.
            curlData="$(jq --arg input "${1%%.*}" '. += {"name": $input, "ttl": 300, "priority": 0}' <<< "${curlData:-{\}}")"

            # Determine data type.
            if [[ "${2}" != "${2#*[0-9].[0-9]}" ]]; then
                curlData="$(jq --arg input "${2}" '. += {"data": $input, "type": "A"}' <<<  "${curlData:-{\}}")"
            elif [[ "${2}" != "${2#*:[0-9a-fA-F]}" ]]; then
                curlData="$(jq --arg input "${2}" '. += {"data": $input, "type": "AAAA"}' <<<  "${curlData:-{\}}")"
            fi

            curlOutput="$(mktemp)"

            # Get existing recordId
            recordId="$(get_domains_records "${1}" | jq -r --arg type "$(jq -r '.type' <<< "${curlData}")" '.[] | select(.type == $type) | .id')"

            [[ ! -z "${recordId}" ]] && {

                # Patch an existing record
                http_code=`curl --silent --location --request PATCH --url "${vultr_uri}${postDomain}/${recordId}" \
                                --header "Content-Type: application/json" \
                                --header "Authorization: Bearer ${vultr_auth}" \
                                --data "${curlData}" --write-out "%{http_code}" --output "${curlOutput}"`

                # Output data posted
                curlData="$(jq --arg input "${recordId}" '. += {"id": $input}' <<<  "${curlData:-{\}}")"
                jq '.' <<< "${curlData}"

            } || {

                # Post a new record
                http_code=`curl --silent --location --request POST --url "${vultr_uri}${postDomain}" \
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
        unset curlData curlOutput http_code postDomain postPayload recordId
    fi
}
