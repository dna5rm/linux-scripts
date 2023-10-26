function wait_animation() {
    # Read PID of the last command and displays a rolling ball it finishes.

    PID=${!}; sp="◐◓◑◒"; i=1
    while [ -d "/proc/${PID}" ]; do
        printf "\b\b ${sp:i++%${#sp}:1} "
        sleep 1
    done; tput el
}
