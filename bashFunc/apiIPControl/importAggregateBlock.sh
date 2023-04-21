## Import an aggregate block
# The importAggregateBlock operation enables you to insert an intermediate level aggregate block between existing blocks in the block hierarchy. By specifying a parent block, target block, and a container, the service will handle validating and inserting the desired aggregate block. The service will also adjust the parent block assignments of any would-be child blocks.
#
# Ref: https://${ipcontrol_uri}/inc-rest/api/docs/index.html

function importAggregateBlock ()
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
	 --data-urlencode "ipAddress=${1}" --url "${ipcontrol_uri}/Imports/importAggregateBlock"
   fi
}
