# This bash function takes in a date as input and calculates the time difference between dates and returns minutes/seconds ago.

function relative() {
    local last_unix="$(date --date="${1}" +%s)"    # convert date to unix timestamp
    local now_unix="$(date +'%s')"

    local delta=$(( ${now_unix} - ${last_unix} ))

    if (( ${delta} < 60 )); then
        echo "${delta} seconds ago"
        return
    elif ((delta < 2700)); then  # 45 * 60
        echo "$(( ${delta} / 60 )) minutes ago";
    fi
}
