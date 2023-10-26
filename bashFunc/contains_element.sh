# Function: Check if $2 (array) contains $1 (string)
contains_element () {
    local e
    for e in "${@:2}"; do
        [[ "$e" == "$1" ]] && return 1
    done
    return 0
}
