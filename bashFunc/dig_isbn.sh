# Dig a book by ISBN (or whatever).

function dig_isbn ()
{
    # Verify function requirements
    for req in box_text curl jq python3; do
        type ${req} >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}"):${FUNCNAME[0]} - cmd/function \"${req}\" is required!"
            return 1
        }
    done

    # Print reference if conditions missing.
    if [[ -z "${1}" ]]; then
        box_text "$(basename "${0}"):${FUNCNAME[0]} - Scrape a book by ISBN."
        echo "Search: \${1} (${1:-missing})

        Aborting..." | sed 's/^[ \t]*//g'
    else

        # Create directory to cache output for this function.
        cache_dir="${HOME}/.cache/$(basename "${0}")"
        [[ ! -d "${cache_dir}" ]] && {
            mkdir -p -m 700 "${cache_dir}"
        }

        # Create a hash of arguments
        execHash="$(echo "${@,,}" | md5sum -t | awk '{print $1}')"

        # Make Query URL safe.
        query="$(echo "${@,,}" | python3 -c "import urllib.parse; print(urllib.parse.quote(input()))")"

        # Perform lookup.
        if [ ! -f "${cache_dir}/${FUNCNAME[0]}_${execHash}" ]; then
            wget "http://books.google.com/books/feeds/volumes?q=${query}&start-index=1&max-results=1" --quiet --output-document=- |\
                python3 -c "$(echo '|import sys,json,xmltodict
                                    |data = {}
                                    |for key,value in xmltodict.parse(sys.stdin.read())["feed"]["entry"].items():
                                    |  if key.startswith("dc:") == True:
                                    |    data[key.replace("dc:","")] = value
                                    |print(json.dumps(data,indent=2))' | sed 's/^[ \t]*|//g')" |\
                tee "${cache_dir}/${FUNCNAME[0]}_${execHash}" | jq '.'

        else
            jq '.' "${cache_dir}/${FUNCNAME[0]}_${execHash}"
        fi
    fi
}
