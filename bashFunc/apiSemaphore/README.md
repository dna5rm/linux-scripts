# Ansible Semaphore API cURL Library

The Ansible Semaphore API cURL library provides a way to interact with available [Semaphore APIs](https://www.ansible-semaphore.com/api-docs/) on your system using a shell script.

# Example Usage

```bash
#!/bin/env -S bash

## Bash functions to load.
bashFunc=(
    "apiSemaphore/user/getUsers"
    "apiSemaphore/authentication/postAuthLogin"
    "apiSemaphore/authentication/postAuthLogout"
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
semaphore_api="http://192.0.2.100:3000/api"
semaphore_auth='{"auth": "administrator", "password": "Nd1g2@cm"}'

## Main Script.

# Login and fetch cookie.
postAuthLogin

# List users on the system.
jq '.' <(getUsers)

# Logout and destroy cookie.
postAuthLogout
```
