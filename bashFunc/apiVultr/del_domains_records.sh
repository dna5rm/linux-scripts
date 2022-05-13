## Delete DNS Record(s)
# Delete the DNS records for the Domain.
#
# Ref: https://www.vultr.com/api/

function del_domains_records ()
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
    if [[ -z "${vultr_uri}" ]] || [[ -z "${vultr_auth}" ]] || [[ -z "${1}" ]]; then
        boxText "$(basename "${0}"):${FUNCNAME[0]} - Delete DNS Record(s)"
        echo "API Base URI: \${vultr_uri} (${vultr_uri:-missing})
        Auth API Key: \${vultr_auth} (${vultr_auth:-missing})
        FQDN: \${1} (${1:-missing})

        Aborting..." | sed 's/^[ \t]*//g'
    else
        # Test user input for domain & append the record id.
        [[ ! -z "$(echo "${1}" | grep -P '(?=^.{1,254}$)(^(?>(?!\d+\.)[a-zA-Z0-9_\-]{1,63}\.?)+(?:[a-zA-Z]{2,})$)')" ]] && {
            delDomain="/domains/${1#*.}"

            # Get a list of all record id's
            get_domains_records "${1}" | jq -r '.[].id' | while read record; do

            # If ${record} is a uuid value
            [[ ! -z "$(echo "${record}" | grep -P '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$')" ]] && {
                delRecord="/records/${record}"

                curlOutput="$(mktemp)"
                http_code=`curl --silent --location --request DELETE --url "${vultr_uri}${delDomain}${delRecord}" \
                            --header "Content-Type: application/json" \
                            --header "Authorization: Bearer ${vultr_auth}" \
                            --write-out "%{http_code}" --output "${curlOutput}"`

                    # Validate http return code.
                    [[ "${http_code}" != "204" ]] && {
                        echo "$(basename "${0}"):${FUNCNAME[0]} - Bad HTTP response code (${http_code})"
                        rm "${curlOutput}"
                        return 1
                    } || {
                        jq '.' "${curlOutput}"
                        rm "${curlOutput}"
                    }
                }
            done

            # Cleanup Variables.
            unset curlOutput http_code delDomain delRecord
        }
    fi
}
