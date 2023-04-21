## Import a zone resource record
# The importZoneResourceRecord operation enables you to import a DNS resource record for a zone to IPControl. Note: this interface should not be confused with the ImportDomainResourceRecord API, which is used to add records to a domain. ImportZoneResourceRecord is only effective when the 'Automatic Generation of NS/Glue Records' is set to OFF on the target zone.
#
# Ref: https://${ipcontrol_uri}/inc-rest/api/docs/index.html

function importZoneResourceRecord ()
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
	 --data-urlencode "ipAddress=${1}" --url "${ipcontrol_uri}/Imports/importZoneResourceRecord"
   fi
}
