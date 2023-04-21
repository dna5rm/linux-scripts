## Export device UDF tags
# After the initExportDevice API is called to initialize the API, the web service client can, optionally, call the initExportDeviceUDFTags API. This service is used by the ExportDevice CLI to create the header line used when exporting with the expanded format option. The result returned from the initExportDeviceUDFTags service is an array of strings. These are the field names/tags of the user defined fields defined for the devices that will be returned on subsequent calls to the exportDevice service.
#
# Ref: https://${ipcontrol_uri}/inc-rest/api/docs/index.html

function initExportDeviceUDFTags ()
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
	 --data-urlencode "ipAddress=${1}" --url "${ipcontrol_uri}/Exports/initExportDeviceUDFTags"
   fi
}
