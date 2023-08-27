#!/bin/env -S bash

. ${HOME}/bin/bashFunc/j2y.sh
. ${HOME}/bin/bashFunc/y2j.sh

##### WARNING #####
# This, run only once, script was used to scrape & create all the bash functions against the swagger docs.
###################
[[ ! -f "_swagger.json" ]] && {
    . ${HOME}/bin/bashFunc/y2j.sh
    curl --silent https://raw.githubusercontent.com/ansible-semaphore/semaphore/develop/api-docs.yml | y2j | jq '.' > _swagger.json
}
###################

[[ -f "_swagger.json" ]] && {

# Extract paths.
paths=( `jq -r '.paths | keys | @tsv' _swagger.json | tac` )
for path in ${paths[@]}; do

##### Extract methods.
    methods=( `jq -r --arg path ${path} '.paths[$path] | del(.["parameters"]) | keys | @tsv' _swagger.json` )
    for method in ${methods[@]}; do

######### Extract variables.
        description=`jq -r --arg path ${path} --arg method ${method} 'try(.paths[$path][$method].description)' _swagger.json`
        parameters=`jq -r --arg path ${path} --arg method ${method} 'try(.paths[$path][$method].parameters)' _swagger.json`
        responses=`jq -r --arg path ${path} --arg method ${method} 'try(.paths[$path][$method].responses)' _swagger.json`
        summary=`jq -r --arg path ${path} --arg method ${method} 'try(.paths[$path][$method].summary)' _swagger.json`
        tags=`jq -r --arg path ${path} --arg method ${method} 'try(.paths[$path][$method].tags|last)' _swagger.json | grep -v ^"null"$`

        schema=`jq -r 'try(.[]["schema"]|.)' <<<${parameters}`
        output="${method}$(sed 's/\/{[^}]*}//g;s/\// /g;s/\b\(.\)/\u\1/g;s/ //g' <<<${path})"
        echo "### [${count:-0}] ${path} (${method}) > ${output}.sh ###"

######### Generate API function script.
        [[ "${output}" != postAuth* ]] && {
        install -m 644 -D <(echo) "./${tags}/${output}.sh"

	cat <<-EOF | awk '{gsub(/\r/, ""); print}' > "./${tags}/${output}.sh"
	## ${output} # ${summary}
	# ${path}

	function ${output} ()
	{
	    # Verify function requirements
	    for req in curl; do
	        type ${req} >/dev/null 2>&1 || {
	            echo >&2 "\$(basename "\${0}" 2> /dev/null):\${FUNCNAME[0]} - \${req} is not installed. Aborting."
	            exit 1
	        }
	    done

	    if [[ -z "\${semaphore_api}" ]] || [[ ! -f "\${HOME}/.cache/semaphore.cookie" ]]` [[ "$(awk -F"{" '{print NF-1}' <<<${path})" -gt 1 ]] && { echo " || [[ -z \"\\\${$(awk -F"{" '{print NF-1}' <<<${path})}\" ]]"; }`; then
	$(printf "\t")cat <<-EOF
	$(printf "\t")\$(basename "\${0}" 2> /dev/null):\${FUNCNAME[0]} - ${summary}
	$(printf "\t")Ref: ${path:-null}
	$(printf "\t")---
	$(printf "\t")API Base URI: \\\${semaphore_api} (\${semaphore_api:-required})
	$(printf "\t")Authentication Cookie: postAuthLogin.sh (\$(test -f "\${HOME}/.cache/semaphore.cookie" && echo "present" || echo "missing"))
	$(printf "\t\n\t")$(echo "Parameter Schema" | sed "1 s,.*,$(tput smso)&$(tput sgr0),"
	if [[ `jq -r 'try(.|keys[])' <<<${schema}` == "\$ref" ]]; then
            jq "$(jq -r 'try(.["$ref"])' <<<${schema} | sed 's/^#//;s/\//\./g').properties" _swagger.json | j2y
        elif [[ ! -z `jq -r 'try(.|keys|.type)' <<<${schema}` ]]; then
            jq '.properties' <<<${schema} | j2y
        fi | sed 's/^/\t/')
	$(printf "\t")EOF
	    else
	        response=\$(curl --silent --insecure --location --write-out "%{http_code}" \\
	          --request ${method^^} --url "\${semaphore_api}/$(for i in $(echo ${path} | sed 's/\// /g'); do [[ "${i:0:1}" != "{" ]] && { echo "${i}"; } || { echo "\${$((${pcount:-0}+1))}"; let ++pcount; }; done | sed -z 's/\n/\//g;s/\/$//')" \\
	          --header "Content-Type: application/json" \\
	          --cookie "\${HOME}/.cache/semaphore.cookie" --data "\${$(( $(awk -F"{" '{print NF-1}' <<<${path}) + 1 )):-{\}}")
	        http_code=\$(tail -n1 <<< "\${response}")

	        # Return response or error description.
	        case "\${http_code}" in
	$(jq -r 'keys[] as $k | "\($k)\t\(.[$k] | .description)"' <<<${responses} | while read code desc; do [[ "${code}" != 2* ]] && {
	    echo "            ${code})"
	    echo "                echo \"[${code}] ${desc}\""
	    echo "                ;;"
	}; done)
	            *)
	                # return the content
	                sed '\$ d' <<< "\${response}"
	                ;;
	        esac

	    fi
	}
	EOF
        }

        let count++
    done
done

}
