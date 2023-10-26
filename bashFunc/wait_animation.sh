function wait_animation() {
# Displays a rolling ball while waiting for a command to finish.
# Usage: wait_animation

    local command=${@}
    local sp="◐◓◑◒"
    local i=1
    local PID

    # Run the command in the background and get its PID
    $command & PID=${!}

    # Check if the command is still running
    while [ -d "/proc/${PID}" ]; do
        # Print the current ball character
        printf "\b\b ${sp:i++%${#sp}:1} "
        sleep 1
    done

    # Clear the animation and print a new line
    tput el
    printf "\n"

}
