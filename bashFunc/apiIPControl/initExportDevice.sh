## Export devices
# The initExportDevice operation enables you to export devices from IPControl. You can filter the list of devices retrieved. When recurseContainerHierarchy is specified in the options array, the service recursively exports all devices within all child containers specified within the Container Selector filter. This flag is ignored if a Container Selector is not included. When pageSize and firstResultPos are specified, a list of structures is returned as described for the exportDevice operation. Otherwise, the returned structure can be passed on a subsequent exportDevice operation to retrieve results.
#
# Ref: https://${ipcontrol_uri}/inc-rest/api/docs/index.html

function initExportDevice ()
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
	 --data-urlencode "ipAddress=${1}" --url "${ipcontrol_uri}/Exports/initExportDevice"
   fi
}
