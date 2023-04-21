## Export resource record pending approvals
# The initExportResourceRecordPendingApproval operation enables you to issue a request to retrieve a list of resource records that are waiting for approval by the invoking administrator. This service enables the client to filter the list of resource records retrieved by requesting administrator, domain name/type and the requested action. There are no options defined for this operation. When pageSize and firstResultPos are specified, a list of structures is returned as described for the exportResourceRecordPendingApproval operation. Otherwise, the returned structure can be passed on a subsequent exportResourceRecordPendingApproval operation to retrieve results.
#
# Ref: https://${ipcontrol_uri}/inc-rest/api/docs/index.html

function initExportResourceRecordPendingApproval ()
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
	 --data-urlencode "ipAddress=${1}" --url "${ipcontrol_uri}/Exports/initExportResourceRecordPendingApproval"
   fi
}
