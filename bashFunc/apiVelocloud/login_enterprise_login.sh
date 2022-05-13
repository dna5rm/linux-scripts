## Authenticate enterprise or partner (MSP) user
# Authenticates an enterprise or partner (MSP) user and, upon successful login, returns a velocloud.session cookie.
# Pass this session cookie in the authentication header in subsequent VCO calls.
#
# Ref: https://vdc-repo.vmware.com/vmwb-repository/dcr-public/e38833e0-7853-44ed-ad72-3512d3d4b20c/6daf405b-b387-4c49-b577-3b28e800ddac/swagger-5.0.0-dist.json

function login_enterprise_login ()
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
	API Username & Password: \${velocloud_auth} (${velocloud_auth:-missing})
	EOF
	exit 1
    else

	# Create directory to cache cookie
	cache_dir="${HOME}/.cache/$(basename "${0}")"
	[[ ! -d "${cache_dir}" ]] && { mkdir -p -m 700 "${cache_dir}"; }

	if [[ -f "${cache_dir}/${FUNCNAME[0]}.cookie" ]] && [[ ! `find "${cache_dir}/${FUNCNAME[0]}.cookie" -mmin +1440` ]]
         then cat "${cache_dir}/${FUNCNAME[0]}.cookie"
         else http_code="$(curl --silent --location --request POST --url "${velocloud_uri}/login/enterpriseLogin" --header "Content-Type: application/json" --data "${velocloud_auth}" --cookie-jar "${cache_dir}/${FUNCNAME[0]}.cookie" --write-out "%{http_code}")"

              [[ "${http_code}" != "200" ]] && {
		echo "$(basename "${0}"):${FUNCNAME[0]} - Bad HTTP response code (${http_code})"
		exit 1
	      } || {
		cat "${cache_dir}/${FUNCNAME[0]}.cookie"
              }
        fi
    fi
}
