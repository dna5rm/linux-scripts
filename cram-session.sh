#!/bin/env -S bash
## Quiz user based against input file.

# Verify script requirements
for req in dialog jq shuf; do
    type ${req} >/dev/null 2>&1 || {
        echo >&2 "$(basename "${0}"): I require ${req} but it's not installed. Aborting."
        exit 1
    }
done && umask 0077

# Exit if no user input
if [[ ! -f "${1}" ]]; then
    echo "$(basename "${0}"): Quiz user against input file."
    echo "File input is required to continue!"
    echo
    echo "Example input file:"
    echo '[{ "Question": "This is a question?", "Answers": [[ "correct", true ],[ "incorrect", false ]], "Explanation": "That was a question." }]' | jq '.'
    exit 0
else
    if jq -e '.' "${1}" >/dev/null 2>&1; then
        input="${1}"
    else
        echo "$(basename "${0}"): No valid json input."
        exit 0
    fi
fi

alphabet=( `echo {A..Z}` )

### Main Loop ###

while true; do
    if [[ -z "${randq}" ]]; then
        randq="$(shuf -i 0-$(jq '.|length-1' "${input}") -n 1)"
    fi && randa=( $(shuf -i 0-$(jq -r --arg q "${randq}" '.[$q|fromjson].Answers|length-1' "${input}")) )

    # Correct Response
    correct=( $(for a in ${randa[@]}; do
        ans="$(jq -r --arg a "${a}" --arg q "${randq}" '.[$q|fromjson].Answers[$a|fromjson]|select(.[1] == true)|.[0]' "${input}")"
        if [[ -n "${ans}" ]]; then
            echo "${alphabet[${ittr:-0}]}"
        fi && ittr=$((${ittr:-0} + 1))
        done) )

    # Dialog type
    if [[ "${#correct[@]}" -eq 1 ]]; then
        dtype="radiolist"
    else
        dtype="checklist"
    fi

    # jq --arg q "${randq}" '.[$q|fromjson].Question' "${input}" | termux-tts-speak -r 1.5 &

    # Dialog String
    execs="dialog --backtitle "${input}" --title ".[${randq}]" --no-cancel --${dtype} "$(jq --arg q "${randq}" '.[$q|fromjson].Question' "${input}")" 0 0 0 \
    $(for a in ${randa[@]}; do
        printf "${alphabet[${ittr:-0}]^^} $(jq --arg a "${a}" --arg q "${randq}" '.[$q|fromjson].Answers[$a|fromjson][0]' "${input}") off "
        ittr=$((${ittr:-0} + 1))
    done)"

    # Dialog Query
    select=( $(bash -c "${execs}" 3>&1 1>&2 2>&3) )

    # Exit Loop if no response
    [[ -z "${select}" ]] && {
        exit 0
    }

    # Report
    if [[ "${correct[@]}" != "${select[@]}" ]]; then
        dialog --backtitle "${input}" --title ".[${randq}]" --msgbox "Question: $(jq -r --arg q "${randq}" '.[$q|fromjson].Question' "${input}")

        Answer:
        $(for a in ${randa[@]}; do
            ans="$(jq -r --arg a "${a}" --arg q "${randq}" '.[$q|fromjson].Answers[$a|fromjson]|select(.[1] == true)|.[0]' "${input}")"
            [[ -n "${ans}" ]] && {
                echo " [${alphabet[${ittr:-0}]}] ${ans}"
            }
            ittr=$((${ittr:-0} + 1))
        done)

        Explanation: $(jq -r --arg q "${randq}" '.[$q|fromjson].Explanation // empty' "${input}")" 0 0
    else
        unset randq
    fi

done
