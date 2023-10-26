function genpasswd () {
# Generate a random password string.

    # Set default length to 16 if no argument is provided
    local length="${1:-16}"

    # Use tr command to generate random characters
    # and store them in a variable
    local password=$(tr -dc 'a-zA-Z0-9!@#$%^&*()' < /dev/urandom | head -c "$length")

    # Print the generated password
    echo "$password"

}
