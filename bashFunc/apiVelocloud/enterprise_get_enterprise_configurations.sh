## Get enterprise configuration profiles
# Gets all configuration profiles, with optional Edge and/or module details, for the specified enterprise.
#
# Ref: https://vdc-repo.vmware.com/vmwb-repository/dcr-public/e38833e0-7853-44ed-ad72-3512d3d4b20c/6daf405b-b387-4c49-b577-3b28e800ddac/swagger-5.0.0-dist.json

function enterprise_get_enterprise_configurations ()
{
    # Verify function requirements
    for req in curl
     do type ${req} >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}"):${FUNCNAME[0]} - ${req} is not installed. Aborting."
            exit 1
        }
    done

    if [[ -z "${velocloud_uri}" ]] || [[ -z "${velocloud_auth}" ]]; then
	cat  <<-EOF
	$(basename "${0}"):${FUNCNAME[0]} - Missing Variable or Input...
	Velocloud API Base URI: \${velocloud_uri} (${velocloud_uri:-missing})
	Privileges required: \${velocloud_session} (${velocloud_session:-missing})
        Enterprise ID: \${1} (${1:-missing})
	EOF
	exit 1
    else
	curlData="$(jq --null-input --arg id "${1}" '{ "id": $id }')"
	curlOutput="$(mktemp)"
	http_code=`curl --silent --location --request POST --url "${velocloud_uri}/enterprise/getEnterpriseConfigurations" \
			 --header "Content-Type: application/json" \
			 --cookie <(echo "${velocloud_session}") \
			 --data "${curlData}" --write-out "%{http_code}" --output "${curlOutput}"`

	[[ "${http_code}" != "200" ]] && {
	    echo "$(basename "${0}"):${FUNCNAME[0]} - Bad HTTP response code (${http_code})"
	    rm "${curlOutput}"
	    exit 1
	} || {
	    cat "${curlOutput}"
	    rm "${curlOutput}"
	}

	unset curlData curlOutput http_code
    fi
}
