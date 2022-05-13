#!/bin/bash
## VS Code Server helper script for Termux

# Enable for debuging.
# set -x

DISTRO="debian"
RELEASES="https://github.com/coder/code-server/releases"
#LATEST="$(curl "${RELEASES}" 2> /dev/null | sed -e 's/<[^>]*>//g;s/ //g' | awk -F'-' '/linux-arm64.tar.gz/{print $3; exit}')"
LATEST="4.0.1"

# Verify script requirements.
for req in curl proot-distro; do
    type ${req} >/dev/null 2>&1 || {
        echo >&2 "$(basename "${0}"): I require ${req} but it's not installed. Aborting."
        exit 1
    }
done && umask 0077

# Run code-server inside proot-distro
if [[ "${EUID}" -eq 0 ]] && [[ "$(uname -r)" == *"faked" ]]; then

    # Download & Install code-server
    if ! type "code-server" > /dev/null 2>&1; then
        curl "${RELEASES}/download/v${LATEST}/code-server-${LATEST}-linux-arm64.tar.gz" \
            --output "code-server-${LATEST}-linux-arm64.tar.gz" --location
        tar -xvf "${HOME}/code-server-${LATEST}-linux-arm64.tar.gz"
        rm "${HOME}/code-server-${LATEST}-linux-arm64.tar.gz"
        mv "${HOME}/code-server-${LATEST}-linux-arm64" /lib/
        ln -fs "/lib/code-server-${LATEST}-linux-arm64/code-server" /bin/
    fi

    # Run code-server
    if type code-server >/dev/null 2>&1; then
        code-server --auth none
    fi

# Login to proot-distro
elif [[ "$(uname -o)" == "Android" ]]; then

    # Install proot distro
    if [[ ! -d "${PREFIX}/var/lib/proot-distro/installed-rootfs/${DISTRO,,}/" ]]; then
        proot-distro install "${DISTRO,,}"
    fi

    # Login to proot distro
    if [[ -d "${PREFIX}/var/lib/proot-distro/installed-rootfs/${DISTRO,,}/" ]]; then
        proot-distro login "${DISTRO,,}" --termux-home -- "${0}"
    fi

# Environment condition issue
else
    echo "$(basename "${0}"): VS Code Server helper script for Termux."
fi
