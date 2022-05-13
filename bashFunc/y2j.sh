# Convert YAML to JSON from stdin.

function y2j ()
{
    # Verify requirements
    for req in python3; do
        type ${req} >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}"):${FUNCNAME[0]} - cmd/function \"${req}\" is required!"
            return 1
        }
    done

    if [[ ${#} -eq 0 ]] && [[ ! -t 0 ]]; then
        python3 -c 'import sys,yaml,json; print(json.dumps(yaml.safe_load(sys.stdin.read()),indent=2))' 2> /dev/null || {
            echo "python3:${FUNCNAME[0]} - Check if PyYAML module is installed."
            return 1
        }
    else
        # Skip basename if shell function
        [[ "${0}" != "-bash" ]] && {
                echo -n "$(basename "${0}"):"
        }
        echo "${FUNCNAME[0]} - Convert YAML to JSON from stdin."
    fi
}
