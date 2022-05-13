#!/bin/bash
## Convert ASA access-list rules to a parseable YAML format.
## 2018 (v.01) - Script from www.davideaves.com

### VARIABLES ###

asa_config_file="${1}"
search_string="${2}"

### MAIN SCRIPT ###

[ -z "${asa_config_file}" ] && { echo -e "${0} - ERROR: missing ASA config"; exit 0; }

for ACCESSGROUP in `awk '/^access-group /{print $2}' "${asa_config_file}" | sort --ignore-case`
 do

  echo "${ACCESSGROUP}:"
  awk 'BEGIN{ REMARK=""; ACTION=""; SERVICE=""; SOURCE=""; DESTINATION=""; PORT=""; LOG=""; DISABLED=""; previous="" }

        # convert number to bits
        function bits(N){
          c = 0
          for(i=0; i<8; ++i) if(and(2**i, N)) ++c
          return c
        }

        # convert ipv4 to prefix
        function to_prefix(mask) {
          split(mask, octet, ".")
          return bits(octet[1]) + bits(octet[2]) + bits(octet[3]) + bits(octet[4])
        }

        # test if a string is an ipv4 address
        function is_v4(address) {
          split(address, octet, ".")
          if ( octet[1] <= 255 && octet[2] <= 255 && octet[3] <= 255 && octet[4] <= 255 )
          return address
        }

        # Only look at access-lists lines
        /^access-list '''${ACCESSGROUP}''' .*'''${search_string}'''/{

        # If line is a remark store it else continue
        if ( $3 == "remark" ) { $1=$2=$3=""; REMARK=substr($0,4) }
        else { $1=$2=$3=""; gsub("^   ", "")

          # Itterate through columns
          for(col = 1; col <= NF; col++) {

           # Append prefix to SOURCE & DESTINATION
           if ( is_v4(previous) && is_v4($col) ) {
            if ( DESTINATION != "" ) { DESTINATION=DESTINATION"/"to_prefix($col); previous="" }
            else if ( SOURCE != "" ) { SOURCE=SOURCE"/"to_prefix($col); previous="" }
          } else {

            # Determine col variable
            if ( col == "1" ) { ACTION=$col; SERVICE=""; SOURCE=""; DESTINATION=""; PORT=""; LOG=""; DISABLED=""; previous="" }
            else if ( $col ~ /^(eq|interface|object|object-group)$/ ) { previous=$col }
            else if ( SERVICE == "" && $col !~ /^(host|object|object-group)$/ ) { SERVICE=$col; PORT=""; previous="" }
            else if ( SOURCE == "" && $col !~ /^(host|object|object-group)$/ ) {
              if ( previous == "interface" ) { SOURCE=previous"/"$col }
              else { SOURCE=$col }; PORT=""; previous=to_prefix($col) }
            else if ( DESTINATION == "" && $col !~ /^(host|object|object-group)$/ ) {
              if ( previous == "interface" ) { DESTINATION=previous"/"$col }
              else { DESTINATION=$col }; PORT=""; previous=to_prefix($col) }
            else if ( previous ~ /^(eq|object-group)$/ ) { PORT=$col; previous="" }
            else if ( $col == "log" ) { LOG=$col; previous="" }
            else if ( $col == "inactive" ) { DISABLED=$col; previous="" }
            else { LAST=$col; previous="" }

          }

        }}

        # Display the output
        if ( DESTINATION != "" ) { count++
          print "  - name: '''${ACCESSGROUP}''' rule",count,"line",NR
          print "    debug:",$0
          if ( REMARK != "" ) { print "    description:",REMARK }
          print "    action:",ACTION
          print "    source:",SOURCE
          print "    destination:",DESTINATION
          if ( PORT == "" ) { print "    service:",SERVICE }
          else { print "    service:",SERVICE"/"PORT }
          if ( LOG != "" ) { print "    log: true" }
          if ( DISABLED != "" ) { print "    disabled: true" }
          REMARK=""; ACTION=""; SERVICE=""; SOURCE=""; DESTINATION=""; PORT=""; LOG=""; DISABLED=""; previous=""
        }

  }' "${asa_config_file}"

done | sed 's/*/_/g'
