## Import an administrator
# The ImportAdmin operation enables you to import administrators to IPControl. It can also be used to modify an existing administrator by specifying its id. Note that while adminstrators of administrator type 'NORMAL' can import and modify administrators and their roles, only MASTER administrators can import or update administrator policies and assignable roles. NORMAL administrators will receive an error message if policies or assignable roles are specified on import. On an import request to modify an administrator, if a NORMAL administrator specifies policies or assignable roles, that information is ignored. To modify an administrator, specify id.
#
# Ref: https://${ipcontrol_uri}/inc-rest/api/docs/index.html

function importAdmin ()
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
	 --data-urlencode "ipAddress=${1}" --url "${ipcontrol_uri}/Imports/importAdmin"
   fi
}
