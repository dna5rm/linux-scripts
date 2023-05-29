#!/bin/env -S bash
##### WARNING #####
# This, run only once, script was used to scrape & create all the bash functions against the swagger docs.
###################

[[ -f "_swagger.json" ]] && {

# Extract session paths.
## I manually edited logout.sh since its a one-off.
#session_paths=( `jq -r '.paths | with_entries(select(.key|startswith("/log"))) | keys | @tsv' _swagger.json` )
for path in ${session_paths[@]}; do

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
	
	    if [[ -z "\${vco_uri}" ]] || [[ -z "\${vco_auth}" ]]` [[ ${inputs:-0} != "0" ]] && { echo " || [[ -z \"\\\${${inputs}}\" ]]"; }`; then
	$(printf "\t")cat <<-EOF
	$(printf "\t")\$(basename "\${0}" 2> /dev/null):\${FUNCNAME[0]} - ${summary}
	$(printf "\t")Ref: ${path:-null}
	$(printf "\t")---
	$(printf "\t")API Base URI: \\\${vco_uri} (\${vco_uri:-required})
	$(printf "\t")Auth Username/Password: \\\${vco_auth} (\${vco_auth:-required})
	$(printf "\t")
	`awk '{print "\t"$0}' "parameters.${operationId}.tmp"`
	$(printf "\t")
	`awk '{print "\t"$0}' "responces.${operationId}.tmp"`
	$(printf "\t")
	$(printf "\t")EOF
	    elif [[ ! -f "\${HOME}/.cache/vco_auth.cookie" ]]; then
	        curl --silent --insecure --location --request ${method^^} --url "\${vco_uri}/${path}" \\
	          --header "Content-Type: application/json" \\
	          --cookie-jar "\${HOME}/.cache/vco_auth.cookie" --data "\${vco_auth:-{\}}"
	    fi
	}
	EOF

######### Cleanup tmp files...
        rm "parameters.${operationId}.tmp" "responces.${operationId}.tmp"
        let count++
    done
done

########################################################

# Extract paths.
paths=( `jq -r '.paths | with_entries(select(.key|startswith("/log")|not)) | keys | @tsv' _swagger.json` )
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
	
	    if [[ -z "\${vco_uri}" ]] || [[ ! -f "\${HOME}/.cache/vco_auth.cookie" ]]` [[ ${inputs:-0} != "0" ]] && { echo " || [[ -z \"\\\${${inputs}}\" ]]"; }`; then
	$(printf "\t")cat <<-EOF
	$(printf "\t")\$(basename "\${0}" 2> /dev/null):\${FUNCNAME[0]} - ${summary}
	$(printf "\t")Ref: ${path:-null}
	$(printf "\t")---
	$(printf "\t")API Base URI: \\\${vco_uri} (\${vco_uri:-required})
	$(printf "\t")Authentication Cookie: login_enterprise_login.sh (\$(test -f "\${HOME}/.cache/vco_auth.cookie" && echo "present" || echo "missing"))
	$(printf "\t")
	`awk '{print "\t"$0}' "parameters.${operationId}.tmp"`
	$(printf "\t")
	`awk '{print "\t"$0}' "responces.${operationId}.tmp"`
	$(printf "\t")
	$(printf "\t")EOF
	    else
	        curl --silent --insecure --location --request ${method^^} --url "\${vco_uri}/$(for i in $(echo ${path} | sed 's/\// /g'); do [[ "${i:0:1}" != "{" ]] && { echo "${i}"; } || { echo "\${$((${pcount:-0}+1))}"; let ++pcount; }; done | sed -z 's/\n/\//g;s/\/$//')" \\
	          --header "Content-Type: application/json" \\
	          --cookie "\${HOME}/.cache/vco_auth.cookie" --data "\${$(( ${inputs} + 1 )):-{\}}"
	    fi
	}
	EOF

######### Cleanup tmp files...
        rm "parameters.${operationId}.tmp" "responces.${operationId}.tmp"
        let count++
    done
done

}
