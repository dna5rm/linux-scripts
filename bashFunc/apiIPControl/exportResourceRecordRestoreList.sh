## Export resource record restore list
# The exportResourceRecordRestoreList API enables you to issue a request to retrieve a list of resource records that have been deleted and may be eligible for restoring. Before invoking the exportResourceRecordRestoreList operation, you must use initExportResourceRecordRestoreList to initialize the API. The response returned from the init operation becomes the input to this operation.
#
# Ref: https://${ipcontrol_uri}/inc-rest/api/docs/index.html

function exportResourceRecordRestoreList ()
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
	 --data-urlencode "ipAddress=${1}" --url "${ipcontrol_uri}/Exports/exportResourceRecordRestoreList"
   fi
}
