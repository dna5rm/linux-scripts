#!/bin/bash
## KeePassXC helper for CLI.

# Verify script requirements
for req in dialog jq keepassxc-cli tput
 do type ${req} >/dev/null 2>&1 || { echo >&2 "$(basename "${0}"): I require ${req} but it's not installed. Aborting."; exit 1; }
done && umask 0077

# Read/Create script variables file
if [ -e "${HOME}/.kprc" ]
 then . "${HOME}/.kprc"
 else cat << EOF >> "${HOME}/.kprc"
kp_pass="$(tr -dc A-Za-z0-9_ < /dev/urandom | head -c 32)"
kp_keyx="\${HOME}/Documents/$(whoami).keyx"
kp_kdbx="\${HOME}/Documents/$(whoami).kdbx"
EOF
fi

### FUNCTIONS ###

function kp_clip () {
 if [[ "$(uname -o)" == "Android" ]]
  then echo "Clipboard: ${1}"
       termux-clipboard-set "$(jq -r '.[].Password //empty' <<< $(kp_show "${1}"))"
  else echo "${1}: $(jq -r '.[].Password //empty' <<< $(kp_show "${1}"))"
 fi
}

function kp_new () {
 # Template to use
 kp_template=$(kp_show "Sample Entry")

 # Create dialog for input
 readarray -t kp_array < <(dialog --backtitle "keepassxc-cli $(keepassxc-cli --version)" --title "${kp_kdbx}" --form "${1:-Sample Entry}" 10 45 3 \
   "Title"    1 1 "$(jq -r '.[].Title' <<< ${kp_template:-[]})" 1 10 30 0 \
   "UserName" 2 1 "$(jq -r '.[].UserName //empty' <<< ${kp_template:-[]})" 2 10 30 0 \
   "URL"      3 1 "$(jq -r '.[].URL //empty' <<< ${kp_template:-[]})" 3 10 30 0 \
  3>&1 1>&2 2>&3)

 # Add new kp entry
 if [[ ! -z "${kp_array[0]}" ]] && [[ -z "$(kp_find "${kp_array[0]}" 2> /dev/null)" ]]
  then echo "${kp_pass}" | keepassxc-cli add "${kp_kdbx}" --key-file "${kp_keyx}" --quiet \
        --username "${kp_array[1]}" --url "${kp_array[3]}" "${kp_array[0]}" -g -L 20 -l -U -n -s --exclude-similar 2> /dev/null
 fi
}

function kp_find () {
 echo "${kp_pass}" | keepassxc-cli locate "${kp_kdbx}" --key-file "${kp_keyx}" --quiet "${1:-Sample Entry}" 2> /dev/null
}

function kp_list () {
 echo "${kp_pass}" | keepassxc-cli ls "${kp_kdbx}" --key-file "${kp_keyx}" --quiet "${1:-/}" 2> /dev/null | while read entry
  do if [[ "${entry: -1}" == "/" ]]
      then echo "$(tput sgr0)$(tput setaf 4)${entry}$(tput sgr0)"
      else echo "${entry}"
     fi
 done | sort
}

function kp_show () {
 echo "${kp_pass}" | keepassxc-cli show "${kp_kdbx}" --key-file "${kp_keyx}" --quiet --show-protected "${1:-Sample Entry}" 2> /dev/null | while read key value
  do key="$(echo "${key}" | tr -cd '[:alnum:]._-')"
     tmp_json="$(jq -c --arg inc "${i:-0}" --arg value "${value}" '.[$inc|fromjson] += {"'''${key}'''": $value}' <<< "${tmp_json:-[]}")"
     echo "${tmp_json}"
 done | tail -n 1
}

### BEGIN ###

if [[ "${1}" == "help" ]]
 then echo "$(basename "${0}") [clip new find show] \"entry name\""
 elif [[ "${1}" == "clip" ]]
  then kp_clip "${2}"
 elif [[ "${1}" == "new" ]]
  then kp_new "${2}"
 elif [[ "${1}" == "find" ]]
  then kp_find "${2}"
 elif [[ "${1}" == "show" ]]
  then kp_show "${2}" | jq
 else kp_list "${1}"
fi

### FINISH ###
