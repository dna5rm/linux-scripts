#!/bin/env -S bash
# Shell script to interface with the Alpaca LLM.
## Alpaca - https://github.com/antimatter15/alpaca.cpp
## Glow - https://github.com/charmbracelet/glow

# Verify script requirements.
for req in alpaca glow jq; do
    type ${req} >/dev/null 2>&1 || {
        echo >&2 "$(basename "${0}"): I require ${req} but it's not installed. Aborting."
        exit ${?}
    }
done && umask 0077

function alpaca_completions() {
    # Return a completion response from provided prompt.

    # Variable of where this function is being called from.
    FUNC_SOURCE="$(basename "${0}" 2> /dev/null)$([[ ! -z "${FUNCNAME[0]}" ]] && { echo "/${FUNCNAME[0]}"; })"

    # Validate we have user_input.
    [[ ! -z "${user_input}" ]] && {

        # Create a hash of arguments for caching.
        CACHE="${HOME}/.cache/$(basename "${FUNC_SOURCE}")"
        HASH="$(awk '{$1=$1};1' <<<${user_input[@],,} | md5sum -t | awk '{print $1}')"

        # Fetch the response & cache (requery if previous cache is +30 days old).
        if [[ ! -f "${CACHE}/${HASH}" ]] || [[ $(find "${CACHE}/${HASH}" -mtime +30 -print) ]]; then

            # Build query arguments for Alpaca.
            [[ -z "${alpaca_data}" ]] && {
                alpaca_data="$(jq --null-input -c --arg model "${ALPACA_MODEL:-/opt/ggml-alpaca-7b-q4.bin}" \
                  --arg prompt "${ALPACA_PROMPT:-You are a helpful assistant.}" \
                  --arg temp "${ALPACA_TEMP:-0.7}" --arg threads "$((($(nproc --all)*3)/4))" \
                  --arg user "$(whoami)" '{
                "model": $model|tostring,
                "prompt": $prompt|tostring,
                "temperature": $temp|tonumber,
                "threads": $threads|tonumber,
                "user": $user|tostring
                }')"
            }

            # Fetch the response to the user request.
            response="$(alpaca -m "${ALPACA_MODEL:-/opt/ggml-alpaca-7b-q4.bin}" --color \
              --prompt "${ALPACA_PROMPT:-You are a helpful assistant.}" \
              --temp ${ALPACA_TEMP:-0.7} --threads $((($(nproc --all)*3)/4)) \
              --file <(echo "${user_input[@]}") 2>> "/dev/null" | sed "s/\[[0-9]\+\]//g")"

            # Append the request & response to alpaca_data.
            alpaca_data=`jq -c --arg request "${user_input}" '. += {"request": $request|tostring}' \
              <<<${alpaca_data}`
            alpaca_data=`jq -c --arg response "${response}" '. += {"response": $response|tostring}' \
              <<<${alpaca_data}`

            # Cache the response.
            install -m 644 -D <(echo "${alpaca_data}") "${CACHE:-alpaca_completions}/${HASH}"
        else
            alpaca_data=`jq -c '.' "${CACHE:-alpaca_completions}/${HASH}"`
        fi

        # Return the last message content.
        type glow >/dev/null 2>&1 && {
            jq -r '. | "# "+ .model, "", .response' <<<${alpaca_data} | glow
        } || {
            jq -r '. | "# "+ .model, "", .response' <<<${alpaca_data}
        }

    } || {
        echo "$(basename "${FUNC_SOURCE}"): \${user_input} is missing."
    }
}

function wait_animation() {
    # Read PID of the last command and displays a rolling ball it finishes.

    PID=${!}; sp="◐◓◑◒"; i=1
    while [ -d "/proc/${PID}" ]; do
        printf "\b\b ${sp:i++%${#sp}:1} "
        sleep 1
    done; printf "\033[2K\r"
}

# Entry point to script functions.
[[ -f "${ALPACA_MODEL:-/opt/ggml-alpaca-7b-q4.bin}" ]] && {

    # Use args or stdin as input.
    [[ -t 0 ]] && {
        user_input="${@}"
    } || {
        user_input=$(</dev/stdin)
    }

    alpaca_completions &
    wait_animation

} || {
    echo "$(basename "${0}"): \${ALPACA_MODEL} is not set or missing."
}
