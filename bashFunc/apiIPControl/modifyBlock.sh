## Modify a Block
# The modifyBlock operation enables you to update certain fields in an existing Block. To modify a block, use this call in conjunction with the getBlock operation. First, retrieve the block the getBlock operation. Then, modify the returned structure. Lastly, pass that modified structure to this operation as the 'block' parameter. If the block id is supplied (as it will be following a getBlock), or the block is not in overlapping space, the container parameter is not required.
#
# Ref: https://${ipcontrol_uri}/inc-rest/api/docs/index.html

function modifyBlock ()
{
    # Verify function requirements
    for req in curl
     do type  >/dev/null 2>&1 || {
        echo >&2 "$(basename "${0}"):${FUNCNAME[0]} - ${req} is not installed. Aborting."
        exit 1
        }
    done

    if [[ -z "${ipcontrol_uri}" ]] || [[ -z "${auth_basic}" ]] || [[ -z "${1}" ]]; then
        cat  <<-EOF
	$(basename "${0}"):${FUNCNAME[0]} - Missing Variable or Input...
	IPControl API Base URI: \${ipcontrol_uri} (${ipcontrol_uri:-missing})
	API Authorization Key: \${auth_basic} (${auth_basic:-missing})
	ipAddress: \${1} (${1:-missing})
	EOF
    else
        ### post ###
        echo curl --silent --insecure --location --get \
	 --header "Authorization: Basic ${auth_basic}" --header "Content-Type: application/json" --header "Accept: application/json" \
	 --data-urlencode "ipAddress=${1}" --url "${ipcontrol_uri}/Imports/modifyBlock"
   fi
}
