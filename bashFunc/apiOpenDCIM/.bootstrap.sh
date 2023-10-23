#!/bin/env -S bash
##### WARNING #####
# This, run only once, script was used to scrape & create all the bash functions against the swagger docs.
###################
[[ ! -f "_swagger.json" ]] && {
    . "${HOME}/bin/bashFunc/y2j.sh"

    # Read credentials from vault.
    [[ -f "${HOME}/.loginrc.vault" && "${HOME}/.vaultpw" ]] && {
        auth_key=`yq -r '.tacacs | "\(.username):\(.password)" | @base64' <(ansible-vault view "${HOME}/.loginrc.vault" --vault-password-file "${HOME}/.vaultpw")`
    } || {
        echo "$(basename "${0}"): Unable to get creds from vault."
        exit 1;
    }

    curl --silent --insecure --location --request GET --url "https://${1}/api/docs/swagger.yaml" \
         --header "Content-Type: application/json" --header "Authorization: Basic ${auth_key}" | y2j | tee _swagger.json
}
###################

[[ -f "_swagger.json" ]] && {

# Extract paths.
paths=( `jq -r '.paths | keys | @tsv' _swagger.json` )
for path in ${paths[@]}; do

##### Extract methods.
    methods=( `jq -r --arg path ${path} '.paths[$path] | keys | @tsv' _swagger.json` )
    for method in ${methods[@]}; do

######### Extract variables.
        description=`jq -r --arg path ${path} --arg method ${method} '.paths[$path][$method].description' _swagger.json`
        operationId=`jq -r --arg path ${path} --arg method ${method} '.paths[$path][$method].operationId' _swagger.json`
        produces=`jq -r --arg path ${path} --arg method ${method} '.paths[$path][$method].produces[0]' _swagger.json`
        responces=( `jq -r --arg path ${path} --arg method ${method} '.paths[$path][$method].responses | keys | @tsv' _swagger.json` )
        summary=`jq -r --arg path ${path} --arg method ${method} '.paths[$path][$method].summary' _swagger.json`

        echo "### [${count:-0}] ${path} -- ${operationId} (${method}) ###"

######### Create tmp file with the paramter documentation.
        printf "%-15s %-7s %-7s %-8s %s\n" "Paramater" "Input" "Req." "Type" "Description" | sed "1 s,.*,$(tput smso)&$(tput sgr0)," > "parameters.${operationId}.tmp"
        jq -r --arg path ${path} --arg method ${method} '.paths[$path][$method].parameters[] | [ .name, .in, .required, .type //false, .allowEmptyValue //false, .description //null] | @tsv' _swagger.json 2> /dev/null |\
         while read name in req type empty desc; do
            printf "%-15s %-7s %-7s %-8s %s\n" "${name}" "${in}" "${req}" "${type}" "${desc}"
        done >> "parameters.${operationId}.tmp"

######### Create tmp file with the responce codes.
        printf "%-5s %s\n" "Code" "Description" | sed "1 s,.*,$(tput smso)&$(tput sgr0)," > "responces.${operationId}.tmp"
        for responce in ${responces[@]}; do
            printf "%-5s %s\n" "${responce}" "$(jq -r --arg path ${path} --arg method ${method} --arg responce ${responce} '.paths[$path][$method].responses[$responce].description' _swagger.json)"
        done >> "responces.${operationId}.tmp"

        inputs=`awk '/ path / {count++} END{print count}' "parameters.${operationId}.tmp"`

######### Generate API function script.
        cat <<-EOF | awk '{gsub(/\r/, ""); print}' > "${operationId}.sh"
	## ${operationId} # ${summary}
	# ${path}
	
	function ${operationId} ()
	{
	    # Verify function requirements
	    for req in curl; do
	        type ${req} >/dev/null 2>&1 || {
	            echo >&2 "\$(basename "\${0}" 2> /dev/null):\${FUNCNAME[0]} - \${req} is not installed. Aborting."
	            exit 1
	        }
	    done
	
	    if [[ -z "\${opendcim_uri}" ]] || [[ -z "\${auth_key}" ]]` [[ ${inputs:-0} != "0" ]] && { echo " || [[ -z \"\\\${${inputs}}\" ]]"; }`; then
	$(printf "\t")cat <<-EOF
	$(printf "\t")\$(basename "\${0}" 2> /dev/null):\${FUNCNAME[0]} - ${summary}
	$(printf "\t")Ref: ${path:-null}
	$(printf "\t")---
	$(printf "\t")API Base URI: \\\${opendcim_uri} (\${opendcim_uri:-required})
	$(printf "\t")Authorization Key: \\\${auth_key} (\${auth_key:-required})
	$(printf "\t")
	`awk '{print "\t"$0}' "parameters.${operationId}.tmp"`
	$(printf "\t")
	`awk '{print "\t"$0}' "responces.${operationId}.tmp"`
	$(printf "\t")
	$(printf "\t")EOF
	    else
	        curl --silent --insecure --location --request ${method^^} --url "\${opendcim_uri}/$(for i in $(echo ${path} | sed 's/\// /g'); do [[ "${i:0:1}" != "{" ]] && { echo "${i}"; } || { echo "\${$((${pcount:-0}+1))}"; let ++pcount; }; done | sed -z 's/\n/\//g;s/\/$//')" \\
	          --header "Accept: ${produces}" \\
	          --header "Authorization: Basic \${auth_key}" \\
	          --header "Content-Type: application/json" \\
	          --data "\${$(( ${inputs} + 1 )):-{\}}"
	    fi
	}
	EOF

######### Cleanup tmp files...
        rm "parameters.${operationId}.tmp" "responces.${operationId}.tmp"
        let count++
    done
done

}
