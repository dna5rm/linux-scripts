#!/bin/env -S bash
## Generate Certificate

# Enable for debuging
# set -x

# Script variables
cert_name=( ${@,,} )
cert_path="." #"$(dirname "${BASH_SOURCE[0]}:-.")"

# Verify script requirements
for req in openssl tput; do
    type ${req} >/dev/null 2>&1 || {
        echo >&2 "$(basename "${0}"): I require ${req} but it's not installed. Aborting."
        exit 1
    }
done && umask 0077

# Script Functions
function boxText () {
    # Contunue if no error code.
    [[ ${?} -eq 0 ]] && {
        # Print reference if conditions missing.
        if [[ -z "${1}" ]]; then
            # Skip basename if shell function
            [[ "${0}" != "-bash" ]] && {
                echo -n "$(basename "${0}"):"
            }
            echo "${FUNCNAME[0]} - Return a simple text box out of text."
            echo "Text: \${1} (${1:-required})" | sed 's/^[ \t]*//g'
        else
            local s=( "${@}" ) b w

            for l in "${s[@]}"; do
                (( w < ${#l} )) && {
                    b="${l}"
                    w="${#l}"
                }
            done

            tput setaf 3
            echo -en "+-${b//?/-}-+\n"

            for l in "${s[@]}"; do
                printf '| %s%*s%s |\n' "$(tput setaf 4)" "-$w" "${l}" "$(tput setaf 3)"
            done

            echo -en "+-${b//?/-}-+\n"
            tput sgr 0
        fi
    }
}

# Display Script Banner
tput setaf 3
cat << EOF
┏━┓┏━┓╻   ┏━┓╻ ╻
┗━┓┗━┓┃   ┗━┓┣━┫
┗━┛┗━┛┗━╸╹┗━┛╹ ╹

EOF
tput sgr0

# Only run if domain name passes validation!
[[ ! -z "$(echo "${cert_name[0]}" | grep -P '(?=^.{1,254}$)(^(?>(?!\d+\.)[a-zA-Z0-9_\-]{1,63}\.?)+(?:[a-zA-Z]{2,})$)')" ]] && {

    # passphrase & private key
    [[ ! -d "${cert_path}/${cert_name[0]}" ]] && {
        tput sgr0 && boxText "SSL Private Key..."

        mkdir -m 755 "${cert_path}/${cert_name[0]}"

        # passphrase.txt
        [[ ! -f "${cert_path}/${cert_name[0]}/passphrase.txt" ]] && {
        python3 <<-EOF > "${cert_path}/${cert_name[0]}/passphrase.txt"
	import random,string
	chars = string.ascii_letters + string.digits + "!@#$%^&*()"
	rnd = random.SystemRandom()
	print("".join(rnd.choice(chars) for i in range(30)))
	EOF
        }

        # privkey.pem
        tput setaf 5 && [[ ! -f "${cert_path}/${cert_name[0]}/privkey.pem" ]] && {
            CMD="openssl genrsa -f4 -passout pass:$(printf "%q" $(cat "${cert_path}/${cert_name[0]}/passphrase.txt")) -des3 -out \"${cert_path}/${cert_name[0]}/privkey.pem\" 4096"
            printf "$(tput sgr0)>>> $(tput setaf 2)%s$(tput sgr0)\n" "${CMD}"
            eval "${CMD}" && unset CMD

            CMD="openssl rsa -passin pass:$(printf "%q" $(cat "${cert_path}/${cert_name[0]}/passphrase.txt")) -noout -check -in \"${cert_path}/${cert_name[0]}/privkey.pem\""
            printf "$(tput sgr0)>>> $(tput setaf 2)%s$(tput sgr0)\n" "${CMD}"
            eval "${CMD}" && unset CMD
        }
    }

    # certificate signing request
    [[ ! -f "${cert_path}/${cert_name[0]}/request.pem" ]] && {
        tput sgr0 && boxText "Certificate Signing Request..."

        # owner information
        read -e -i "$(awk -F' = ' '/^C /{print $NF}' "${cert_path}/${cert_name[0]}/request.conf" 2> /dev/null || echo "US")" -p "Country: " cert_countryName
        read -e -i "$(awk -F' = ' '/^L /{print $NF}' "${cert_path}/${cert_name[0]}/request.conf" 2> /dev/null || echo "New York")" -p "State/Province: " cert_stateOrProvinceName
        read -e -i "$(awk -F' = ' '/^O /{print $NF}' "${cert_path}/${cert_name[0]}/request.conf" 2> /dev/null || echo "ACME Corporation.")" -p "Organization: " cert_organizationName
        read -e -i "$(awk -F' = ' '/^CN /{print $NF}' "${cert_path}/${cert_name[0]}/request.conf" 2> /dev/null || echo "${cert_name[0]}")" -p "Common Name: " cert_commonName

        # request.conf
        cat <<-EOF > "${cert_path}/${cert_name[0]}/request.conf"
	[req]
	distinguished_name = req_distinguished_name
	req_extensions = v3_req
	prompt = no

	[req_distinguished_name]
	C = ${cert_countryName}
	L = ${cert_stateOrProvinceName}
	O = ${cert_organizationName}
	CN = ${cert_commonName}

	[v3_req]
	keyUsage = keyEncipherment, dataEncipherment
	extendedKeyUsage = serverAuth
	$([[ ${#cert_name[@]} -ge 2 ]] && {
	cat <<-ALT
	subjectAltName = @alt_names

	[alt_names]
	$(for i in $(seq 1 ${#cert_name[@]}); do echo "DNS.${i} = ${cert_name[$((i-1))]}"; done)
	ALT
	})
	EOF

        # request.pem
        tput setaf 5 && [[ ! -f "${cert_path}/${cert_name[0]}/request.pem" ]] && {
            CMD="openssl req -new -passin pass:$(printf "%q" $(cat "${cert_path}/${cert_name[0]}/passphrase.txt")) -key \"${cert_path}/${cert_name[0]}/privkey.pem\" -out \"${cert_path}/${cert_name[0]}/request.pem\" -config \"${cert_path}/${cert_name[0]}/request.conf\""
            printf "$(tput sgr0)>>> $(tput setaf 2)%s$(tput sgr0)\n" "${CMD}"
            eval "${CMD}" && unset CMD

            CMD="openssl req -noout -text -in \"${cert_path}/${cert_name[0]}/request.pem\""
            printf "$(tput sgr0)>>> $(tput setaf 2)%s$(tput sgr0)\n" "${CMD}"
            eval "${CMD}" && unset CMD
        }
    }

    # self-signed certificate
    [[ ! -f "${cert_path}/${cert_name[0]}/selfsign.pem" ]] && {
        tput sgr0 && boxText "SSL Self-Signed Cert w/bundle..."

        # days to expire
        [[ -f "${cert_path}/${cert_name[0]}/selfsign.pem" ]] && {
            cert_exp="$(( $(( $(date +%s -d "$(openssl x509 -in "${cert_path}/${cert_name[0]}/selfsign.pem" -enddate -noout | awk -F'=' '{print $NF}')") - $(date +%s -d now) )) / 86400 ))"
        }

        # create if <= 14 days
        tput setaf 5 && [[ ${cert_exp:-0} -le 14 ]] && {
            # selfsign.pem
            CMD="openssl x509 -passin pass:$(printf "%q" $(cat "${cert_path}/${cert_name[0]}/passphrase.txt")) -req -days 365 -in \"${cert_path}/${cert_name[0]}/request.pem\" -signkey \"${cert_path}/${cert_name[0]}/privkey.pem\" -out \"${cert_path}/${cert_name[0]}/selfsign.pem\""
            printf "$(tput sgr0)>>> $(tput setaf 2)%s$(tput sgr0)\n" "${CMD}"
            eval "${CMD}" && unset CMD

            CMD="openssl x509 -in \"${cert_path}/${cert_name[0]}/selfsign.pem\" -noout -text"
            printf "$(tput sgr0)>>> $(tput setaf 2)%s$(tput sgr0)\n" "${CMD}"
            eval "${CMD}" && unset CMD

            # selfsign.pfx
            CMD="openssl pkcs12 -export -passin pass:$(printf "%q" $(cat "${cert_path}/${cert_name[0]}/passphrase.txt")) -passout pass:$(printf "%q" $(cat "${cert_path}/${cert_name[0]}/passphrase.txt")) -inkey \"${cert_path}/${cert_name[0]}/privkey.pem\" -in \"${cert_path}/${cert_name[0]}/selfsign.pem\" -out \"${cert_path}/${cert_name[0]}/selfsign.pfx\""
            printf "$(tput sgr0)>>> $(tput setaf 2)%s$(tput sgr0)\n" "${CMD}"
            eval "${CMD}" && unset CMD

            CMD="openssl pkcs12 -passin pass:$(printf "%q" $(cat "${cert_path}/${cert_name[0]}/passphrase.txt")) -passout pass:$(printf "%q" $(cat "${cert_path}/${cert_name[0]}/passphrase.txt")) -in \"${cert_path}/${cert_name[0]}/selfsign.pfx\""
            printf "$(tput sgr0)>>> $(tput setaf 2)%s$(tput sgr0)\n" "${CMD}"
            eval "${CMD}" && unset CMD
        }

        unset cert_exp
    }

    # certificate
    [[ -f "${cert_path}/${cert_name[0]}/certificate.pem" ]] && {
        tput sgr0 && boxText "SSL Certificate Exist..."

        # days to expire
        [[ -f "${cert_path}/${cert_name[0]}/certificate.pem" ]] && {
            cert_exp="$(( $(( $(date +%s -d "$(openssl x509 -in "${cert_path}/${cert_name[0]}/certificate.pem" -enddate -noout | awk -F'=' '{print $NF}')") - $(date +%s -d now) )) / 86400 ))"
        }

        # create if <= 14 days
        tput setaf 5 && [[ ${cert_exp:-0} -le 14 ]] && {
            CMD="openssl x509 -in \"${cert_path}/${cert_name[0]}/certificate.pem\" -noout -text"
            printf "$(tput sgr0)>>> $(tput setaf 2)%s$(tput sgr0)\n" "${CMD}"
            eval "${CMD}" && unset CMD
        }

        if [[ ${cert_exp:-0} -le 14 ]] || [[ ! -f "${cert_path}/${cert_name[0]}/certificate.pfx" ]]; then
            # certificate.pfx
            CMD="openssl pkcs12 -export -passin pass:$(printf "%q" $(cat "${cert_path}/${cert_name[0]}/passphrase.txt")) -passout pass:$(printf "%q" $(cat "${cert_path}/${cert_name[0]}/passphrase.txt")) -inkey \"${cert_path}/${cert_name[0]}/privkey.pem\" -in \"${cert_path}/${cert_name[0]}/certificate.pem\" -out \"${cert_path}/${cert_name[0]}/certificate.pfx\""
            printf "$(tput sgr0)>>> $(tput setaf 2)%s$(tput sgr0)\n" "${CMD}"
            eval "${CMD}" && unset CMD

            CMD="openssl pkcs12 -passin pass:$(printf "%q" $(cat "${cert_path}/${cert_name[0]}/passphrase.txt")) -passout pass:$(printf "%q" $(cat "${cert_path}/${cert_name[0]}/passphrase.txt")) -in \"${cert_path}/${cert_name[0]}/certificate.pfx\""
            printf "$(tput sgr0)>>> $(tput setaf 2)%s$(tput sgr0)\n" "${CMD}"
            eval "${CMD}" && unset CMD
        fi

        unset cert_exp
    } || {
        tput sgr0 && boxText "SSL Certificate Missing..."
        printf "%s\n\n" "Copy certificate to \"${cert_path}/${cert_name[0]}/certificate.pem\""
    }

    # freshen README and file permissions
    [[ -f "${cert_path}/${cert_name[0]}/passphrase.txt" ]] && {
        tput sgr0 && touch "${cert_path}/${cert_name[0]}/README"
        cat <<-EOF > "${cert_path}/${cert_name[0]}/README"
	This directory contains the ssl certificates for ${cert_name[0]}

	$(for file in "${cert_path}/${cert_name[0]}/"*; do
	    echo -n "'$(basename ${file})'^:^"
	    case $(basename ${file}) in
		README*)	echo "information about files.";;
		cert*.pem)	echo "public key certificate. [$(openssl x509 -in "${file}" -enddate -noout | awk -F'=' '{print $NF}')]";;
		cert*.pfx)	echo "public key certificate bundle.";;
		passphrase.txt)	echo "passphrase for certificate.";;
		privkey.pem)	echo "private key certificate.";;
		request.conf)	echo "certificate configuration.";;
		request.pem)	echo "certificate signing request.";;
		self*.pem)	echo "self-signed public key. [$(openssl x509 -in "${file}" -enddate -noout | awk -F'=' '{print $NF}')]";;
		self*.pfx)	echo "self-signed certificate bundle.";;
		*)		echo;;
	    esac
	done | column -ts^)

	EOF
        chmod 644 "${cert_path}/${cert_name[0]}/"*
    }
} || {
# display help
tput sgr0 && boxText "No domain specified..."
cat <<EOF

Usage:

Create a ssl private key & csr for certificate.
$ $(tput bold)${0}$(tput sgr0) example.local

Create a ssl private key & csr for SAN certificate.
The certificate will be named server01.example.local in the following example.
$ $(tput bold)${0}$(tput sgr0) server01.example.local server02.example.local

EOF
}
