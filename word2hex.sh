#!/bin/bash

# List of functions.
bashFunc=(
    "askAlpaca"
    "str2Hex"
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

alpaca_model="${HOME}/opt/ggml-alpaca-7b-q4.bin"
output="${HOME}/$(basename "${0}")/${1,,}.json"

if [[ "${#1}" -eq 6 ]] && [[ ! -f "${output}" ]]; then
    hex="$(str2Hex "${1,,}")"
    [[ "${#hex}" -eq "${#1}" ]] && {
        echo "${1,,} > #${hex}"
        def="$(askAlpaca "Provide me a single sentence definition of the english word \"${1,,}\" in english.")"

        JSON="{}"
        JSON="$(jq --arg word "${1,,}" '. + {"word": $word}' <<<${JSON})"
        JSON="$(jq --arg hex "#${hex}" '. + {"hex": $hex}' <<<${JSON})"
        JSON="$(jq --arg definition "${def}" '. + {"definition": $definition}' <<<${JSON})"

        install -m 644 -D  <(jq -c --sort-keys '.' <<<${JSON}) "${output}"
    }
fi
