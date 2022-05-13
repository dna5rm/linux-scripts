# Convert JSON to YAML from stdin.

function j2y ()
{
    # Verify requirements
    for req in python3; do
        type ${req} >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}"):${FUNCNAME[0]} - cmd/function \"${req}\" is required!"
            return 1
        }
    done

    if [[ ${#} -eq 0 ]] && [[ ! -t 0 ]]; then
        python3 -c 'import sys,yaml,json; yaml.safe_dump(json.load(sys.stdin), sys.stdout, default_flow_style=False)' 2> /dev/null || {
            echo "python3:${FUNCNAME[0]} - Check if PyYAML module is installed."
            return 1
        }
    else
        echo "$(basename "${0}"):${FUNCNAME[0]} - Convert JSON to YAML from stdin."
    fi
}
