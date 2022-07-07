#!/bin/env -S bash

# Verify script requirements.
for req in AtomicParsley ffmpeg jq youtube-dl; do
    type ${req} >/dev/null 2>&1 || {
        echo >&2 "$(basename "${0}"): I require ${req} but it's not installed. Aborting."
        exit 1
    }
done && umask 0022

# Main.
if [[ ! -z "${@}" ]]; then

    for i in ${@}; do

        # Capturing output filename as output to rename the output doesnt seem to work 100%
        # Just run the same again against the info.json file.

        if [[ "$(echo "${i}" | grep -oP 'http.?://\S+')" ]]; then
            youtube-dl --id --no-call-home --add-metadata --embed-thumbnail --write-info-json --write-sub --convert-subs srt --format mp4 --ignore-errors "${i}"
        elif [[ -f "${i%%.*}.info.json" ]]; then
            _id=`jq -r '.id' "${i%%.*}.info.json"`
            _filename=`jq -r '.title' "${i%%.*}.info.json" | sed -e 's/[^A-Za-z0-9. _-]/_/g;s/^[ |_]*//g;s/[ |_]*$//g'`

            [[ ! -z "${_filename}" ]] && {
                echo "[${_id}] ${_filename}"

                jq '. | del(._filename, .automatic_captions, .formats, .http_headers, .subtitles, .thumbnails, .url)' "${i%%.*}.info.json" > "${_filename}.info.json" && rm "${i%%.*}.info.json"
                for f in "${_id}"*; do
                    mv "${f}" "${_filename}.${f##*.}"
                done
            }
        fi

    done
else
    echo "[$(basename "${0}")] Download video(s) from Youtube..."
fi
