function exifRename ()
{
    # Verify requirements
    for req in boxText curl exiftool jq sha1sum tput; do
        type ${req} >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}"):${FUNCNAME[0]} - cmd/function \"${req}\" is required!"
            return 1
        }
    done

    MimeDB=( "https://raw.githubusercontent.com/jshttp/mime-db/master/db.json" "${HOME}/.cache/mime.json" )

    [[ -z "$1" ]] && {
        echo "$(basename "${0}"):${FUNCNAME[0]} - No file to rename \${1}"
        exit 1
    } || {

        # Download MimeDB
        [[ ! -s "${MimeDB[1]}" ]] && {
            curl -s "${MimeDB[0]}" | jq > "${MimeDB[1]}"
        }

        for SourceFile in "${@}"; do

            [[ -f "${SourceFile}" ]] && {
                MIME="$(file -b --mime-type "${SourceFile}")"
                SHA1="$(sha1sum "${SourceFile}" | awk '{print $1}')"

                # JSON Queries
                EXTENSION="$(jq -r --arg MIME "${MIME}" '.[$MIME].extensions[0] // empty' "${MimeDB[1]}")"
                TITLE="$(exiftool -j -TITLE "${SourceFile}" 2> /dev/null | jq -r '.[0].Title // empty')"

                printf "$(tput setab 7; tput setaf 0)${SHA1}$(tput sgr0) ${SourceFile}\n"

                [[ -z "${TITLE}" ]] && {    
                    read -p "Title [${SourceFile%.*}]: " TITLE
                    TITLE="${TITLE:-${SourceFile%.*}}"

                    # Write EXIF Tags
                    exiftool -overwrite_original_in_place -TITLE="${TITLE}" "${SourceFile}"
                }

                [[ "${SourceFile}" != "${TITLE}.${EXTENSION}" ]] && {
                    printf "Rename: ${SourceFile} > ${TITLE}.${EXTENSION}\n"
                    mv "${SourceFile}" "${TITLE}.${EXTENSION}"
                }
            }
        done
    }
}
