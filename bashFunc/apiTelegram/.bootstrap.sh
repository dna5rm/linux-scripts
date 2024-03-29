#!/bin/bash
##### WARNING #####
# This, run only once, script was used to scrape & create all the bash functions against the Telegram API module files.
# Ref: https://core.telegram.org/bots/api
###################

#rm -rf available-* games getting-updates inline-mode payments stickers telegram-passport updating-messages

[[ ! -f "_telegram-api.html" ]] && {
    curl --silent --output "_telegram-api.html" --url "https://core.telegram.org/bots/api"
}

awk -F'[ ><]' '/^.h/{print $2"|"$6"|"$7"|"$15,$16,$17,$18,$19,$20}' "_telegram-api.html" | sed 's/ \/h.//g' | while IFS="|" read CAT NAME HREF DESC; do

    printf "%-4s %-45s %-45s %-45s\n" "${CAT}" "${NAME}" "${HREF}" "${DESC}" | sed "1 s,.*,$(tput smso)&$(tput sgr0),"

    # Get the Category
    if [[ "${CAT,,}" == "h3" ]]; then
        category="$(awk -F'"' '{print $(NF-1)}' <<<${NAME})"

    # Get the Function
    elif [[ "${CAT,,}" == "h4" ]] && [[ "$(wc -w <<<${DESC})" -eq 1 ]]; then
        name="$(echo "${NAME}" | awk -F'"' '{print $2}')"
        href="$(echo "${HREF}" | awk -F'"' '{print $2}')"
        api="$(echo "${DESC}" | awk '{print $1}')"
        fn="${category}/${api}.sh"
        description="$(pandoc --from=html --to=markdown --wrap=preserve -o - <(lynx -source "_telegram-api.html" | sed -n '/^<h.*'''${NAME}'''/,/^<h/p' | sed '1d;$d;s/$^$/<\/p>/;s/<a[^>]\+>/<a>/g;s/<img[^>]\+>//g') | awk -F'.' 'NR<2{print $1"."}' | sed 's/\\//g')"

        rm -rf "_tmp" && pandoc --from=html --to=markdown -o "_tmp" <(lynx -source "_telegram-api.html" | sed -n '/^<h.*'''${NAME}'''/,/^<h/p' | sed '1d;$d;s/$^$/<\/p>/;s/<a[^>]\+>/<a>/g;s/<img[^>]\+>//g') | awk -F'.' '{print "\t"$0}' | sed 's/\\//g;s/`/\\`/g'

#        [[ -z "$(grep "InputFile" "_tmp")" ]] && {
#            content="Content-Type: application/json"
#        } || {
            content="Content-Type: multipart/form-data"
#        }

        # Create directory if missing.
        [[ ! -d "${category}" ]] && mkdir "${category}"

        # Create bash function.
	cat <<-EOF | awk '{gsub(/\r/, ""); print}' | grep -v ^""$ | sed 's/^#$//g' > "${fn}"
	## ${name} # ${description}
	# https://core.telegram.org/bots/api${href}
	#
	function $(echo "${DESC}" | awk '{print $1}') ()
	{
	    # Verify function requirements
	    for req in curl; do
	        type ${req} >/dev/null 2>&1 || {
	            echo >&2 "\$(basename "\${0}" 2> /dev/null):\${FUNCNAME[0]} - \${req} is not installed. Aborting."
	            exit 1
	        }
	    done
	#
	    if [[ -z "\${TELEGRAM_TOKEN}" ]] || [[ -z "\$(grep -E "+{*}+" <<<\${1:-{\}} 2> /dev/null)" ]]; then
	$(printf "\t")cat <<-EOF
	$(printf "\t")\$(basename "\${0}" 2> /dev/null):\${FUNCNAME[0]} - ${description}
	$(printf "\t")Ref: https://core.telegram.org/bots/api${href}
	$(printf "\t")---
	$(printf "\t")Telegram API Token: \\\${TELEGRAM_TOKEN} (\${TELEGRAM_TOKEN:-required})
	$(printf "\t")---
	$(cat "_tmp")
	$(printf "\t")EOF
	    else
                # Construct a curl CMD string to eval
                cmd=( "curl --silent --location --request POST" )
                cmd+=( "--url \"https://api.telegram.org/bot\${TELEGRAM_TOKEN}/${api}\"" )
                cmd+=( "--header \"Content-Type: multipart/form-data\"" )
                cmd+=( "--header \"Accept: application/json\"" )
	#
                # Prevent command injection by filtering through sed.
                cmd+=( \`jq -r 'to_entries[] | "--form \""+"\(.key)=\(.value|@text)\""' <<<"\${@:-{\}}" | sed 's/[\$]/\\\&/g'\` )
	#
                # Run the CMD
                eval \${cmd[@]}
	    fi
	}
	EOF
    fi

done && rm -rf "_telegram-api.html" "_tmp"
