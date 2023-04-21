## Delete tasks by date
# The deleteTaskByDate operation enables you to delete tasks from IPControl that are older than a given date. Specify the date as YYYY-MM-DDTHH:MM:SSZ. Specifying the time following the 'T' is optional. Examples: 2015-04-24T18:35:37.52Z, 2015-04-24T18:35:37Z or 2015-04-24.  The number of tasks deleted is returned in the result.
#
# Ref: https://${ipcontrol_uri}/inc-rest/api/docs/index.html

function deleteTaskByDate ()
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
        ### delete ###
        echo curl --silent --insecure --location --get \
	 --header "Authorization: Basic ${auth_basic}" --header "Content-Type: application/json" --header "Accept: application/json" \
	 --data-urlencode "ipAddress=${1}" --url "${ipcontrol_uri}/Deletes/deleteTaskByDate"
   fi
}
