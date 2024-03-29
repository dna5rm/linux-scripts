#!/bin/bash

# List of functions.
bashFunc=(
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

[[ ! -f "${1}" ]] && {
    echo "$(basename "${0}"): Munge an input wordlist into HexColorWords."
    echo "Missing \"language.txt\" wordlist file as \"\${1}\" input..."
    exit 1
}

# Variables.
language="$(basename "${1}" | sed 's/\..*$//')"
#words=( $(tac "${1}" | tr '[:upper:]' '['lower']' | sed -n '/^[0-9,a,b,c,d,e,f,g,i,l,o,s,t,z]\{6\}$/p' | sort) )
words=( $(sed -n '/^.\{6\}$/p' "${1}" | tr '[:upper:]' '['lower']' | sort | uniq) )

# Main Script.
for word in ${words[@],,}; do

    output="${HOME}/$(basename "${0}" | sed 's/\..*$//')/${language}/${word,,}.json"

    if [[ ! -z "${word,,}.json" ]] && [[ "${#word}" -eq 6 ]] && [[ ! -f "${output}" ]]; then
        hex="$(str2Hex "${word,,}")"
        [[ "${#hex}" -eq "${#word}" ]] && {

            echo "[$((${count:0}+1))/${#words[@]}] ${word,,} > #${hex}"
            def="$(ask_alpaca.sh "Provide me a single sentence definition of the ${language,,} word \"${word,,}\" in english.")"

            JSON="{}"
            JSON="$(jq --arg word "${word,,}" '. + {"word": $word}' <<<${JSON})"
            JSON="$(jq --arg hex "#${hex}" '. + {"hex": $hex}' <<<${JSON})"
            JSON="$(jq --arg definition "${def}" '. + {"definition": $definition}' <<<${JSON})"

            install -m 644 -D  <(jq -c --sort-keys '.' <<<${JSON}) "${output}"
        }
    fi
    let count++

done
