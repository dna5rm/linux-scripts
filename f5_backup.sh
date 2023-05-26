#!/bin/bash
## Create/Backup a UCS file against a list of F5 loadbalancers.
## 2016 (v1.0) - Script from www.davideaves.com

F5HOSTS="xxx yyy"
BACKUPDIR="/opt/f5backup"

# FUNCTION: Fetch the UCS or private id_rsa keyfile.
UCSFETCH() {
 if [ -e "${HOME}/.ssh/f5/${F5,,}.pem" ]
  then
        printf "${F5,,} "

        # Delete backup files older than 90 days.
        find "${BACKUPDIR}" -maxdepth 1 -type f -name "${F5,,}*.ucs" -mtime +90 -exec rm {} \;

        # Create the UCS backup file.
        ssh -q -o StrictHostKeyChecking=no -i "${HOME}/.ssh/f5/${F5,,}.pem" root@${F5,,} "tmsh save /sys ucs $(echo ${F5,,}) > /dev/null 2>&1"

        # Copy down the UCS backup file.
        scp -q -o StrictHostKeyChecking=no -i "${HOME}/.ssh/f5/${F5,,}.pem" root@${F5,,}:/var/local/ucs/${F5,,}.ucs "${BACKUPDIR}/" && UCSRENAME
 else
        printf "\n$F5 "

        # Copy down the F5's private id_rsa keyfile for root user.
        scp -o StrictHostKeyChecking=no root@${F5,,}:/var/ssh/root/identity "${HOME}/.ssh/f5/${F5,,}.pem" 2> /dev/null
 fi
}

# FUNCTION: Rename the UCS file.
UCSRENAME() {
 mv "${BACKUPDIR}/${F5,,}.ucs" "${BACKUPDIR}/$(echo ${F5,,})_$(date +%Y%m%d -d "$(file "${BACKUPDIR}/${F5,,}.ucs" | awk -F': ' '{print $NF}' | awk -F',' '{print $1}')").ucs"
}

### Main Loop ###

for f5host in ${F5HOSTS}
 do f5="$(basename ${f5host##*/} .pem)"

 # Validate host is pingable before fetching UCS file.
 ping -c1 ${f5} > /dev/null 2>&1 && UCSFETCH

done; echo
