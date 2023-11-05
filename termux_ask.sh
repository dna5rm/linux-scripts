#!/bin/bash
# This script is used to ask for user input and generate a response from OpenAI completions.
# To use cp, not ln -s, this script to ~/shortcuts and make sure Termux:Widget is installed.

# Get python version.
python_ver="$(python3 -c 'from sys import version_info as ver; print(ver.major,ver.minor,ver.micro, sep="_")')"

# Check if bluetooth A2DP is on.
HEADSET=`jq '.BLUETOOTH_A2DP_IS_ON' <(termux-audio-info 2> /dev/null)`

# Set variable so only raw output is returned.
MARKDOWN=null

# Check if virtual environment exists and bluetooth headset is connected.
if [[ -d "${HOME}/Projects/venv${python_ver}" ]] && [[ "${HEADSET,,}" == "true" ]]; then

    # Activate python virtual environment.
    source "${HOME}/Projects/venv${python_ver}/bin/activate"

    # Read credentials from vault.
    [[ -f "${HOME}/.loginrc.vault" && "${HOME}/.vault" ]] && {
        OPENAI_API_KEY=`yq -r '.OPENAI_API_KEY' \
          <(ansible-vault view "${HOME}/.loginrc.vault" --vault-password-file "${HOME}/.vault")`
    } || {
        echo "Unable to get creds from vault." | termux-tts-speak
        exit 1;
    }

    # Load bash functions.
    . ~/bin/bashFunc/openai_completions.sh

    # Ask for user input from termux-dialog.
    user_input=`jq -r '.text' <(termux-dialog text -t "$(basename "${0}")" -m)`

    # Get response and speak it through headset.
    openai_completions | tee /dev/stderr | termux-tts-speak -r 1.7

fi
