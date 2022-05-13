#!/bin/env -S bash
# Convert DMS geographic coordinates to Decimal Degrees

#echo "scale=9; ((((45.7100 / 60) + 38) / 60) + 176) * -1" | bc

function usage ()
{
    ### Display the script arguments...

    printf "Usage: $0 -c [N,E,S,W] -d dd -m mm -s sss\n\n"
    printf "Convert DMS to Decimal\n"
}

### Verify & get passed arguments.
while getopts ":c:d:m:s:" ARG; do
    case "${ARG}" in
        c) C=`echo "${OPTARG}" | tr [:lower:] [:upper:]`;;
        d) declare -i D="${OPTARG}";;
        m) declare -i M="${OPTARG}";;
        s) S="${OPTARG}";;
    esac
done

#[ -z "${C}" -o -z "${D}" -o -z "${M}" -o -z "${S}" ] && { usage && exit 1; }

echo "scale=9; (((( ${S} / 60 ) + ${M} ) / 60 ) + ${D} ) `[ ${C} = "S" -o ${C} = "W" ] && { echo "* -1"; }`" | bc | tr -d [:cntrl:]
