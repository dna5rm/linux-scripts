# Return an Alpaca LLM completion response from provided input.

function alpaca_completions() {

    # Get the function source.
    local func_source="${FUNCNAME[0]}"

    # Use user_input var, args or stdin as input.
    [[ -z "${user_input}" ]] && {
        [[ -t 0 ]] && {
            local user_input="${@}"
        } || {
            local user_input=$(</dev/stdin)
        }
    }

    # Run tests and set func_error any fail.
    if ! type alpaca >/dev/null 2>&1; then
        local func_error="Alpaca executable not found."
    elif [[ -z "${user_input}" ]]; then
        local func_error="Missing User input."
    elif ! [[ -f "${ALPACA_MODEL:-/opt/ggml-alpaca-7b-q4.bin}" ]]; then
        local func_error="Model file not found."
    fi

    # Return if any checks failed.
    [[ ! -z "${func_error}" ]] && {
        [[ "${0}" != "-bash" ]] && {
            echo >&2 "$(basename "${0}"):${func_source} - ${func_error}"
        } || {
            echo >&2 "${func_source} - ${func_error}"
        }
        return 1
    } || {
        # Create a hash of the input for caching.
        local cache="${HOME}/.cache/$(basename "${func_source}")"
        local hash="$(awk '{$1=$1};1' <<<${user_input[@],,} | md5sum -t | awk '{print $1}')"

        # Check if there is a cached response and if it is older than 30 days.
        if [[ ! -f "${cache}/${hash}" ]] || [[ $(find "${cache}/${hash}" -mtime +30 -print) ]]; then
            # Build the Alpaca arguments.
            local model="${ALPACA_MODEL:-/opt/ggml-alpaca-7b-q4.bin}"
            local prompt="${ALPACA_PROMPT:-You are a helpful assistant.}"
            local temp="${ALPACA_TEMP:-0.7}"
            local threads="$((($(nproc --all)*3)/4))"
            local user="$(whoami):${FUNC_SOURCE}"

            # Fetch the response from Alpaca.
            local response="$(alpaca -m "${model}" --color --prompt "${prompt}" \
              --temp "${temp}" --threads "${threads}" --file <(echo "${user_input[@]}") 2>> "/dev/null" | sed "s/\[[0-9]\+\]//g")"

            # Append the request & response to alpaca_data.
            local alpaca_data="$(jq -n --arg model "${model}" --arg prompt "${prompt}" \
              --arg temp "${temp}" --arg threads "${threads}" --arg user "${user}" \
              --arg request "${user_input}" --arg response "${response}" '{
                model: $model,
                prompt: $prompt,
                temperature: $temp,
                threads: $threads,
                user: $user,
                request: $request,
                response: $response
              }')"

            # Cache the response.
            install -m 644 -D <(echo "${alpaca_data}") "${cache:-alpaca_completions}/${hash}"
        else
            # Get the cached response.
            local alpaca_data="$(jq -c '.' "${cache:-alpaca_completions}/${hash}")"
        fi

        # Return the response message content.
        if type glow >/dev/null 2>&1; then
            jq -r '. | "# " + .model, "", .response' <<< "${alpaca_data}" | glow
        else
            jq -r '.response' <<< "${alpaca_data}"
        fi
    }
}
