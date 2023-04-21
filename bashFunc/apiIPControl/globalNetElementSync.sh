## Issue Global Synchronization Task for Network Elements
# Issue an immediate Global Synchronization task for all network elements in IPControl that are flagged for inclusion in the Global Sync process. If the task is scheduled successfully, the positive integer returned will correspond to the task number. This task number can be passed to the taskStatus operation to obtain the status of that task. If the task is not scheduled successfully, the negative integer returned in the response contains a code: -1 system error, -2 access denied, -3 invalid parameter, -4 resource not found.
#
# Ref: https://${ipcontrol_uri}/inc-rest/api/docs/index.html

function globalNetElementSync ()
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
	 --data-urlencode "ipAddress=${1}" --url "${ipcontrol_uri}/TaskInvocation/globalNetElementSync"
   fi
}
