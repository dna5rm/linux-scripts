## Export resource record restore list
# The initExportResourceRecordRestoreList API enables the web service client to issue a request to retrieve a list of resource records that have been deleted and may be eligible for restoring. This service enables the client to filter the list of resource records exported. A superuser may filter the results based on the requesting administrator(not available for non-superusers). Resource records deleted from a device may be filtered based on hostname or IP Address of the device. Resource records deleted from a zone may be filtered based on the zone, server or view. There are no options defined for this operation. When pageSize and firstResultPos are specified, a list of structures is returned as described for the exportResourceRecordRestoreList operation. Otherwise, the returned structure can be passed on a subsequent exportResourceRecordRestoreList operation to retrieve results.
#
# Ref: https://${ipcontrol_uri}/inc-rest/api/docs/index.html

function initExportResourceRecordRestoreList ()
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
	 --data-urlencode "ipAddress=${1}" --url "${ipcontrol_uri}/Exports/initExportResourceRecordRestoreList"
   fi
}
