function x2y () {

    # Verify requirements
    for req in python3; do
        type ${req} >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}"):${FUNCNAME[0]} - cmd/function \"${req}\" is required!"
            return 1
        }
    done

    if [[ ${#} -eq 0 ]] && [[ ! -t 0 ]]; then
        python3 -c 'import sys,yaml,xmltodict; print(yaml.dump(xmltodict.parse(sys.stdin.read()),indent=2))' 2> /dev/null || {
            echo "python3:${FUNCNAME[0]} - Check if xmltodict and pyyaml modules are installed."
            return 1
        }
    else
        echo "$(basename "${0}"):${FUNCNAME[0]} - Convert XML to YAML from stdin."
    fi

}
