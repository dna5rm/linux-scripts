#!/bin/env -S bash
##### WARNING #####
# This, run only once, script was used to scrape & create all the bash functions against the documentation on the server.
###################

[[ -z "${1}" ]] && {
    echo "$(basename "${0}"): Missing server name."
    exit 1
} || {
    SERVER="${1}"
}

###

curl --silent --insecure https://${SERVER}/inc-rest/api/swagger.json | jq -r '.paths|keys | @sh' | xargs printf '%s\n' | while read KEY; do

URI="${KEY}"

echo "${KEY}"

FILE="$(basename ${KEY}).sh"
METHOD="$(curl --silent --insecure https://${SERVER}/inc-rest/api/swagger.json | jq -r --arg KEY ${KEY} '.paths[$KEY]|keys | @sh' | xargs printf '%s\n')"
SUMMARY="$(curl --silent --insecure https://${SERVER}/inc-rest/api/swagger.json | jq -r --arg KEY ${KEY} --arg METHOD ${METHOD} '.paths[$KEY][$METHOD].summary')"
DESCRIPTION="$(curl --silent --insecure https://${SERVER}/inc-rest/api/swagger.json | jq -r --arg KEY ${KEY} --arg METHOD ${METHOD} '.paths[$KEY][$METHOD].description')"

cat <<EOF > "${FILE}"
## ${SUMMARY}
# ${DESCRIPTION}
#
# Ref: https://\${ipcontrol_uri}/inc-rest/api/docs/index.html

function $(basename ${KEY}) ()
{
    # Verify function requirements
    for req in curl
     do type ${req} >/dev/null 2>&1 || {
        echo >&2 "\$(basename "\${0}"):\${FUNCNAME[0]} - \${req} is not installed. Aborting."
        exit 1
        }
    done

    if [[ -z "\${ipcontrol_uri}" ]] || [[ -z "\${auth_basic}" ]] || [[ -z "\${1}" ]]; then
        cat  <<-EOF
	\$(basename "\${0}"):\${FUNCNAME[0]} - Missing Variable or Input...
	IPControl API Base URI: \\\${ipcontrol_uri} (\${ipcontrol_uri:-missing})
	API Authorization Key: \\\${auth_basic} (\${auth_basic:-missing})
	ipAddress: \\\${1} (\${1:-missing})
	EOF
    else
        ### ${METHOD} ###
        echo curl --silent --insecure --location --get \\
	 --header "Authorization: Basic \${auth_basic}" --header "Content-Type: application/json" --header "Accept: application/json" \\
	 --data-urlencode "ipAddress=\${1}" --url "\${ipcontrol_uri}${KEY}"
   fi
}
EOF

done
