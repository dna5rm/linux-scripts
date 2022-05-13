#!/bin/env -S bash

## https://wiki.termux.com/wiki/Recover_a_broken_environment
# rm -rf /data/data/com.termux/files/usr

# Packages to install
pkgs=(
    asciidoctor
    bc binutils bmon build-essential
    clamav curl
    dialog dnsutils
    exiftool expect
    fdupes ffmpeg file
    git gnupg golang
    htop
    imagemagick
    jq
    libmaxminddb-tools libzmq
    man moreutils
    ncurses-utils neofetch nmap nodejs
    openssh ossp-uuid
    pdfgrep proot-distro pup python
    rsync rust
    screen
    termux-api
    toilet
    vim
    wget
)

# Install X11 repo
pkgs+=("x11-repo")

# X11 packages to install
case "${pkgs[@]}" in *"x11-repo"*) \
    pkgs_x11=($(echo $(tr ' ' '\n' <<< "dosbox
        feh
        geany
        hexchat
        keepassxc
        netsurf
        obconf openbox
        polybar
        tigervnc
        wireshark-gtk
        xfce4-terminal" | sort -u)))
 ;; esac

# Verbose pkg install
function pkg_install ()
{
    printf "Installing [%s]\n" $@ && echo
    yes | pkg install $@
}

# Upgrade termux & install packages
if type "termux-info" >/dev/null 2>&1; then
    yes | pkg upgrade && {
        echo

        [[ ! -z "${pkgs}" ]] && {
            pkg_install ${pkgs[@]}
            echo
        }

        [[ ! -z "${pkgs_x11}" ]] && {
            pkg_install ${pkgs_x11[@]}
            echo
        }
    }


    [[ -d "${HOME}/.termux" ]] && {
        mkdir -p "${HOME}/.termux"
        for f in ${HOME}/bin/rc_files/termux/*; do
            ln -fs "${f}" "${HOME}/.termux/${f##*/}"
        done
        ln -fs "${PREFIX}/bin/bash" "${HOME}/.termux/shell"
    }

    [[ ! -d "${HOME}/.config/openbox" ]] && {
        mkdir -p "${HOME}/.config"
        ln -fs "${HOME}/bin/rc_files/openbox" "${HOME}/.config/"
    }

    [[ ! -d "${HOME}/.config/xfce4/terminal" ]] && {
        mkdir -p "${HOME}/.config/xfce4/terminal"
        ln -fs "${HOME}/bin/rc_files/xfce4-terminalrc" "${HOME}/.config/xfce4/terminal/terminalrc"
    }
fi
