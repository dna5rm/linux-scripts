# Return crc32 hash from stdin.

function crc32 ()
{
    # Verify requirements
    for req in python3; do
        type ${req} >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}"):${FUNCNAME[0]} - cmd/function \"${req}\" is required!"
            return 1
        }
    done

    if [[ ${#} -eq 0 ]] && [[ ! -t 0 ]]; then
        python3 -c 'import sys,zlib; print("{:x}".format(zlib.crc32(sys.stdin.buffer.read())%(1<<32)))'
    else
        echo "$(basename "${0}"):${FUNCNAME[0]} - Return crc32 hash from stdin."
    fi
}
