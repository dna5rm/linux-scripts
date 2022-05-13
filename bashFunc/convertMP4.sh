# Convert a video file to MP4
## Ref: https://superuser.com/questions/490683/cheat-sheets-and-presets-settings-that-actually-work-with-ffmpeg-1-0

function convertMP4 ()
{
    # Verify requirements
    for req in boxText exiftool ffmpeg; do
        type ${req} >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}"):${FUNCNAME[0]} - cmd/function \"${req}\" is required!"
            return 1
        }
    done

    if [ ! -z "$1" ]; then
        array=( 3gp avi flv mkv mov mp4 mpeg mpg rm webm wmv )

        for file in "$@"; do
            finput="${file}"
            fext="${finput##*.}"
            outdir="${HOME}/converted/"

            # Only run against certain file extionsions
            if [[ " ${array[@]} " =~ " ${fext,,} " ]]; then

                mkdir -p "${outdir}"
                fhash="$(md5sum "${finput}")"
                echo "convert_mp4 $(date +"%d/%b/%Y:%H:%M:%S %z") \"${finput}\" to \"${outdir}/${fhash%% *}.mp4\"" | tee -a "${HOME}/convert_mp4.log"

                # Convert using ffmpg
                if [ ! -f "${outdir}/${fhash%% *}.mp4" ]; then
                    ffmpeg -i "${finput}" -c:v libx264 -preset slow "${outdir}/${fhash%% *}.mp4" 2>> "${HOME}/convert_mp4.log"

                    # Write EXIF tags
                    exiftool -overwrite_original_in_place -title="${finput%.*}" "${outdir}/${fhash%% *}.mp4" >> "${HOME}/convert_mp4.log"
                    exiftool -overwrite_original_in_place -api largefilesupport=1 -tagsFromFile "${finput}" "${outdir}/${fhash%% *}.mp4" >> "${HOME}/convert_mp4.log"
                fi
            fi
        done
    else
        printf "Convert video to MP4...\nUsage: convert_mp4 <input>\n"
    fi
}
