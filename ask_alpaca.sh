#!/bin/env -S bash
# Shell script to interface with the Alpaca LLM.
## Alpaca - https://github.com/antimatter15/alpaca.cpp
## Glow - https://github.com/charmbracelet/glow

## Bash functions to load.
bashFunc=(
    "alpaca_completions"
    "wait_animation"
)

## Load bash functions.
for func in ${bashFunc[@]}; do
    [[ ! -e "$(dirname "${0}")/bashFunc/${func}.sh" ]] && {
        echo "$(basename "${0}"): ${func} not found!"
        exit 1
    } || {
        . "$(dirname "${0}")/bashFunc/${func}.sh"
    }
done || exit 1

# Verify script requirements.
for req in alpaca glow jq; do
    type ${req} >/dev/null 2>&1 || {
        echo >&2 "$(basename "${0}"): I require ${req} but it's not installed. Aborting."
        exit ${?}
    }
done && umask 0077

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
