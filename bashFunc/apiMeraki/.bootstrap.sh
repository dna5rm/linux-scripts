#!/bin/bash
##### WARNING #####
# This, run only once, script was used to scrape & create all the bash functions against the Meraki Python module files.
# Ref: https://github.com/meraki/dashboard-api-python/tree/main/meraki/api
###################

for f in [a-z]*.py; do
[[ ! -d "${f%.*}" ]] && mkdir "${f%.*}"
awk '/^    def /,/^        return /' "${f}" | while read LN; do

    if [[ "${LN%% *}" == "def" ]]; then
        NAME="$(echo ${LN} | awk -F'[(| ]' '{print $2}')"
    elif [[ "${LN%% *}" == "resource" ]]; then
        RESOURCE="$(echo "${LN}" | awk -F "'" '{print $2}')"
    elif [[ "${LN%% *}" == "return" ]]; then
        METHOD="$(echo "${LN}" | awk -F'[.|(|_]' '{print $4}')"

        echo ">>> ${f}/${NAME} <<<"
        PCOUNT="$(echo ${RESOURCE} | tr -cd '{' | wc -c)"

	cat <<-EOF | awk '{gsub(/\r/, ""); print}' | grep -v ^""$ | sed 's/^#$//g' > "${f%.*}/${NAME}.sh"
	## ${NAME} # ${DESC}
	# ${URL}
	#
	function ${NAME} ()
	{
	    # Verify function requirements
	    for req in curl; do
	        type ${req} >/dev/null 2>&1 || {
	            echo >&2 "\$(basename "\${0}" 2> /dev/null):\${FUNCNAME[0]} - \${req} is not installed. Aborting."
	            exit 1
	        }
	    done
	#
	    if [[ -z "\${meraki_uri}" ]] || [[ -z "\${auth_key}" ]] || [[ -z "\${`[[ "${METHOD^^}" == "GET" ]] && { echo "$((${PCOUNT}))"; } || { echo "$((${PCOUNT}+1))"; }`}" ]]; then
	$(printf "\t")cat <<-EOF
	$(printf "\t")\$(basename "\${0}" 2> /dev/null):\${FUNCNAME[0]} - ${DESC}
	$(printf "\t")Ref: ${URL}
	$(printf "\t")---
	$(printf "\t")Meraki API Base URI: \\\${meraki_uri} (\${meraki_uri:-required})
	$(printf "\t")API Authorization Key: \\\${auth_key} (\${auth_key:-required})
	`for i in $(echo ${RESOURCE} | sed 's/\// /g'); do
	    [[ "${i:0:1}" == "{" ]] && {
	        printf "\t%s: \%s %s\n" $(echo "${i}" | sed 's/[}|{]//g') $(echo "\\\${$((${count:-0}+1))}") $(echo "(\\\${$((${count:-0}+1)):-required})")
	        let ++count
	    }
	done | sed -z 's/^$//;/^$/d'
	unset count
	[[ ! ${PCOUNT} -eq 0 ]] && {
	    echo "$(printf "\t")---"
	    [[ "${PARAM}" != "" ]] && {
	        echo "${PARAM}" | sed 's/|/\n/g' | awk '{print "\t"$0}'
	    }; } | grep -ve "(required)" -ve "^	$"`
	$(printf "\t")EOF
	    else
	        `[[ "${METHOD^^}" != "GET" ]] && { echo "### PLACEHOLDER cURL - FIX ME ###
	        echo"; }` curl --silent `[[ "${METHOD^^}" != "GET" ]] && { echo "--output /dev/null --write-out \"%{http_code}\n\" "; }`--location \\
	          --request ${METHOD^^} --url "\${meraki_uri}/$(for i in $(echo ${RESOURCE} | sed 's/\// /g'); do [[ "${i:0:1}" != "{" ]] && { echo "${i}"; } || { echo "\${$((${count:-0}+1))}"; let ++count; }; done | sed -z 's/\n/\//g;s/\/$//')" \\
	          --header "Content-Type: application/json" \\
	          --header "Accept: application/json" \\
	          --header "X-Cisco-Meraki-API-Key: \${auth_key}"`[[ "${METHOD^^}" != "GET" ]] && { printf " \\\\\\\\\n\t  --data \"\\\${$((${count}+2))}\"\n"; }`
	    fi
	}
	EOF
        unset NAME DESC URL PARAM RESOURCE METHOD count
    elif [[ "${LN%% *}" =~ ^\*\* ]]; then
        DESC="$(echo "${LN}" | sed 's/\*//g')"
    elif [[ "${LN%% *}" =~ ^"http" ]]; then
        URL="$(echo "${LN}")"
    elif [[ "${LN%% *}" == "-" ]]; then
        PARAM+="$(echo "${LN}" | sed 's/ (.*):/:/;s/^- /|/')"
#    else
#        echo "||| ${LN}"
    fi
done
done
