#!/bin/env -S bash

# Verify script requirements.
for req in clamscan jq sponge; do
    type ${req} >/dev/null 2>&1 || {
        echo >&2 "$(basename "${0}"): I require ${req} but it's not installed. Aborting."
        exit 1
    }
done && umask 0077

# Exit if no debug or user input
if [[ ! "$SHELLOPTS" =~ "xtrace" ]] && [[ -z "${1}" ]]; then
    echo "$(basename "${0}"): Directory input is required to continue!"
    exit 0
fi

# Set scan output variable.
out="$(basename ${0%.*}).json"
echo "{}" > "${out}"

# Main loop used to scan directory.
clamscan --stdout --no-summary --suppress-ok-results --recursive "${1:-.}" | tee "${out%%.*}.raw" |\
    while read input; do
        hash="$(sha512sum "${input%%': '*}" | awk '{print $1}')"
        match="$(echo "${input##*': '}" | awk '{print $1}')"
        mime="$(file -b --mime-type "${input%%': '*}")"

        # Create tmp infection output for file.
        echo "{}" | jq -c --arg hash "${hash}" --arg match "${match}" --arg mime "${mime}" \
            '. += {($match): [{"hash": $hash, "mime": $mime}]}' > "${hash}.json"

        # Merge infection output into main output.
        jq -s 'def deepmerge(a;b):
        reduce b[] as $item (a;
          reduce ($item | keys_unsorted[]) as $key (.;
           $item[$key] as $val | ($val | type) as $type | .[$key] = if ($type == "object") then
            deepmerge({}; [if .[$key] == null then {} else .[$key] end, $val])
           elif ($type == "array") then
            (.[$key] + $val | unique)
           else
            $val
           end)
          );
         deepmerge({}; .)' "${out}" "${hash}.json" | sponge "${out}"

        # Move and cleanup tmp output.
        if [[ -f "${hash}.json" ]]; then
            install -m 644 -D "${input%%': '*}" -T "vx/${hash}"
            rm "${input%%': '*}" "${hash}.json"
        fi
    done
