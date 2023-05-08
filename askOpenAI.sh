#!/bin/bash
## Use the askOpenAI bash function.

# List of functions.
bashFunc=(
    "askOpenAI"
    "y2j"
)

# Load Bash functions.
for func in ${bashFunc[@]}; do
    [[ ! -e "$(dirname "${0}")/bashFunc/${func}.sh" ]] && {
        echo "$(basename "${0}"): ${func} not found!"
        exit 1
    } || {
        . "$(dirname "${0}")/bashFunc/${func}.sh"
    }
done || exit 1

OPENAI_API_KEY="$(y2j < "${HOME}/.loginrc.yaml" | jq -r '.OPENAI_API_KEY')"

if [[ -z "${@}" ]]; then
    askOpenAI
elif [[ "${1,,}" == "image"* ]]; then
    outputUUID="${HOME}/public_html/img/$(uuid).png"
    install -m 644 -D <(askOpenAI "${@}" | jq -r '.data[0].b64_json' | base64 -d) "${outputUUID}"
    [[ -f "${outputUUID}" ]] && { file "${outputUUID}"; }
else
    askOpenAI "${@}" | jq -r '. | .model, "", .choices[0].text' | sed "1 s,.*,$(tput smso)&$(tput sgr0),"
fi
