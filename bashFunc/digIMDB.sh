# Dig IMDB tags from a title lookup.

function digIMDB ()
{

    # Verify function requirements
    for req in boxText curl jq; do
        type ${req} >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}"):${FUNCNAME[0]} - cmd/function \"${req}\" is required!"
            return 1
        }
    done

    # Print reference if conditions missing.
    if [[ -z "${omdbapi_auth}" ]] || [[ -z "${1}" ]]; then
        boxText "$(basename "${0}"):${FUNCNAME[0]} - Fetch IMDB lookup."
        echo "Auth API Key: \${omdbapi_auth} (${omdbapi_auth:-missing})
        Search: \${1} (${1:-missing})

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
            wget "http://www.omdbapi.com/?t=${query}&apikey=${omdbapi_auth}" --quiet --output-document=- |\
                tee "${cache_dir}/${FUNCNAME[0]}_${execHash}" | jq '.'
        else
            jq '.' "${cache_dir}/${FUNCNAME[0]}_${execHash}"
        fi

    fi
}
