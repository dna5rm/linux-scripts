## Endpointnetworktopologydetails # Endpoint network topology details
# /endpoint-data/network-topology/{networkProbeId}.json

function getEndpointnetworktopologydetails ()
{
    # Verify function requirements
    for req in curl; do
        type  >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - ${req} is not installed. Aborting."
            exit 1
        }
    done

    if [[ -z "${thousandeyes_uri}" ]] || [[ -z "${auth_key}" ]] || [[ -z "${1}" ]]; then
	cat <<-EOF
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Endpoint network topology details
	Ref: /endpoint-data/network-topology/{networkProbeId}.json
	---
	API Base URI: \${thousandeyes_uri} (${thousandeyes_uri:-required})
	Authorization Key: \${auth_key} (${auth_key:-required})
	
	[3mParamater       Input   Req.    Type     Description[m
	Authorization   header  false   string   
	window          query   true    string   
	Content-Type    header  true    string   
	networkProbeId  path    true    string   
	
	[3mCode  Description[m
	200   
	
	EOF
    else
        curl --silent --insecure --location --request GET --url "${thousandeyes_uri}/endpoint-data/network-topology/${1}" \
          --header "Accept: application/json" \
          --header "Authorization: Basic ${auth_key}" \
          --header "Content-Type: application/json" \
          --data "${2:-{\}}"
    fi
}
