## Get DNS Record(s)
# Get the DNS records for the Domain.
#
# Ref: https://www.vultr.com/api/

function get_domains_records ()
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
        boxText "$(basename "${0}"):${FUNCNAME[0]} - Get DNS Record(s)"
        echo "API Base URI: \${vultr_uri} (${vultr_uri:-missing})
        Auth API Key: \${vultr_auth} (${vultr_auth:-missing})
        FQDN: \${1} (${1:-missing})

        Aborting..." | sed 's/^[ \t]*//'
    else
        # Test user input for domain & append the record id.
        [[ ! -z "$(echo "${1}" | grep -P '(?=^.{1,254}$)(^(?>(?!\d+\.)[a-zA-Z0-9_\-]{1,63}\.?)+(?:[a-zA-Z]{2,})$)')" ]] && {

            # Dirty check if host attached to domain.
            [[ "$(echo "${1#*.}" | awk -F'.' '{print NF-1}')" == "1" ]] && {
                getDomain="/domains/${1#*.}/records"
                getRecord="${1%%.*}"
            } || {
                getDomain="/domains/${1}/records"
            }

            curlOutput="$(mktemp)"
            http_code=`curl --silent --location --request GET --url "${vultr_uri}${getDomain}" \
                            --header "Content-Type: application/json" \
                            --header "Authorization: Bearer ${vultr_auth}" \
                            --write-out "%{http_code}" --output "${curlOutput}"`

            # Validate http return code.
            [[ "${http_code}" != "200" ]] && {
                echo "$(basename "${0}"):${FUNCNAME[0]} - Bad HTTP response code (${http_code})"
                rm "${curlOutput}"
                return 1
            } || {

                # Pull out Record if requested.
                [[ -z "${getRecord}" ]] && {
                    # List all records
                    jq '.records' "${curlOutput}"
                } || {
                    # Get specific records
                    jq --arg record "${getRecord}" '[.records[] | select(.name == $record)]' "${curlOutput}"
                }

                rm "${curlOutput}"
            }

            # Cleanup Variables.
            unset curlOutput http_code getDomain getRecord
        }
    fi
}
