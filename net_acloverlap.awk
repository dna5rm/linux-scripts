#!/bin/env -S awk -f
## Report network CIDR overlaps from a list.
## 2018 (v.01) - Script from www.davideaves.com

# Convert IP to Interger.
function ip_to_int(input) {
    split(input, oc, ".")
    ip_int=(oc[1]*(256^3))+(oc[2]*(256^2))+(oc[3]*(256))+(oc[4])
    return ip_int
}

# Convert Interger to IP.
function int_to_ip(input) {
    str=""
    num=input
    for(i=3;i>=0;i--){
        octet = int (num / (256 ^ i))
        str= i==0?str octet:str octet "."
        num -= (octet * 256 ^ i)
    }
    return str
}

## MAIN: Build HOST arrays
//{
    gsub(/\r/, "") # Strip CTRL+M
    split($1, ADDR, "/")

    # line is a CIDR block.
    if(ADDR[2] != "32") {
        NETWORK=ip_to_int(ADDR[1])
        BROADCAST=(NETWORK + (2^(32-ADDR[2]) - 1))

        # Iterate NETWORK until BROADCAST
        COUNT=NETWORK
        while(BROADCAST >= COUNT) {
            if(HOST[int_to_ip(COUNT)] != int_to_ip(COUNT)) {
                HOST[int_to_ip(COUNT)]=int_to_ip(COUNT)
            } else {
                if(PREVIOUS != $1) {
                    printf "OVERLAP: %-18s HINT: %s\n", $1, HOST[int_to_ip(COUNT)]
                    PREVIOUS=$1
                }
            }
            COUNT+=1
        }
    } else {
        # Store /32 host for END
        HOST32[key]=ADDR[1]
        key+=1
    }
}

## Done building arrays.
## Scan for /32 host overlaps

END{
    for(key in HOST32) {
        printf "OVERLAP: %-18s\n", HOST32[key]"/32"
    }
    printf "\n# Hosts: %s\n", length(HOST) + length(HOST32)
}
