# Bash Functions

The following directory is all resuable code as saved as bash functions. Most
of the functions should have built in help which is displayed if its called
by itself with no input.

## Bootstrapping

Paste the following snippet at the start of your script. Any function in the
"bashFunc" list will be loaded. Make sure to exclude the _.sh_ file extension.

```bash
# List of functions.
bashFunc=(
    "box_text"
    "cache_exec"
)

# Load Bash functions.
for func in ${bashFunc[@]}; do
    [[ ! -e "$(dirname "${0}")/bashFunc/${func}.sh" ]] && {
        echo "$(basename "${0}"): ${func} not found!"
        exit 1
    } || {
        . "$(dirname "${0}")/bashFunc/${func}.sh"
    }
done || exit 1
```
