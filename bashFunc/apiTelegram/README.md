# Telegram API cURL Library

The Telegram API cURL library provides all current [Telegram API](https://core.telegram.org/bots/api) calls to interface with the platform.

## Help

Each API has the reference documentation embeded with it. Calling any API with a non-json string (eg: help) will output help.

## Example Usage

```bash
#!/bin/env -S bash

## Bash functions to load.
bashFunc=(
    "apiTelegram/getMe"
)

## Load Bash functions.
for func in ${bashFunc[@]}; do
    [[ ! -e "$(dirname "${0}")/bashFunc/${func}.sh" ]] && {
        echo "$(basename "${0}"): ${func} not found!"
        exit 1
    } || {
        . "$(dirname "${0}")/bashFunc/${func}.sh"
    }
done || exit 1

## Set variables.
TELEGRAM_TOKEN="$(awk '/telegram/{print $NF}' ~/.netrc)"

## Main Script.
getMe | jq '.'
```
