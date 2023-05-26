# Vultr API (2.0) cURL Library
## https://www.vultr.com/api/

## Script Example

```bash
#!/bin/env -S bash

### Verify requirements ###
for req in curl jq; do
    type ${req} >/dev/null 2>&1 || {
        echo >&2 "$(basename "${0}"): I require ${req} but it's not installed. Aborting."
        exit 1
    }
done

### Functions ###

# List of functions.
bashFunc=(
    "apiVultr/get-account"
)

## Load bash functions.
for func in ${bashFunc[@]}; do
    [[ ! -e "$(dirname "${0}")/bashFunc/${func}.sh" ]] && {
        echo "$(basename "${0}"): ${func} not found!"
        exit 1
    } || {
        . "$(dirname "${0}")/bashFunc/${func}.sh"
    }
done || exit 1

### Variables ###
VULTR_API_KEY="XXX..."
VULTR_API_URI="https://api.vultr.com/v2"

# Get Account Info
get-account | jq '.'
```

## API Methods

| Function    | Description |
| ----------- | ----------- |
| attach-block | Attach Block Storage |
| attach-instance-iso | Attach ISO to Instance |
| attach-instance-network | Attach Private Network to Instance |
| attach-instance-vpc | Attach VPC to Instance |
| attach-reserved-ip | Attach Reserved IP |
| convert-reserved-ip | Convert Instance IP to Reserved IP |
| create-baremetal | Create Bare Metal Instance |
| create-block | Create Block Storage |
| create-connection-pool | Create Connection Pool |
| create-database-db | Create Logical Database |
| create-database | Create Managed Database |
| create-database-user | Create Database User |
| create-dns-domain-record | Create Record |
| create-dns-domain | Create DNS Domain |
| create-firewall-group | Create Firewall Group |
| create-instance-backup-schedule | Set Instance Backup Schedule |
| create-instance-ipv4 | Create IPv4 |
| create-instance-reverse-ipv4 | Create Instance Reverse IPv4 |
| create-instance-reverse-ipv6 | Create Instance Reverse IPv6 |
| create-instance | Create Instance |
| create-iso | Create ISO |
| create-kubernetes-cluster | Create Kubernetes Cluster |
| create-load-balancer-forwarding-rules | Create Forwarding Rule |
| create-load-balancer | Create Load Balancer |
| create-network | Create a Private Network |
| create-nodepools | Create NodePool |
| create-object-storage | Create Object Storage |
| create-reserved-ip | Create Reserved IP |
| create-snapshot-create-from-url | Create Snapshot from URL |
| create-snapshot | Create Snapshot |
| create-ssh-key | Create SSH key |
| create-startup-script | Create Startup Script |
| create-user | Create User |
| create-vpc | Create a VPC |
| database-add-read-replica | Add Read-Only Replica |
| database-detach-migration | Detach Migration |
| database-fork | Fork Managed Database |
| database-restore-from-backup | Restore from Backup |
| database-start-migration | Start Migration |
| delete-baremetal | Delete Bare Metal |
| delete-block | Delete Block Storage |
| delete-connection-pool | Delete Connection Pool |
| delete-database-db | Delete Logical Database |
| delete-database | Delete Managed Database |
| delete-database-user | Delete Database User |
| delete-dns-domain-record | Delete Record |
| delete-dns-domain | Delete Domain |
| delete-firewall-group-rule | Delete Firewall Rule |
| delete-firewall-group | Delete Firewall Group |
| delete-instance-ipv4 | Delete IPv4 Address |
| delete-instance-reverse-ipv6 | Delete Instance Reverse IPv6 |
| delete-instance | Delete Instance |
| delete-iso | Delete ISO |
| delete-kubernetes-cluster | Delete Kubernetes Cluster |
| delete-kubernetes-cluster-vke-id-delete-with-linked-resources | Delete VKE Cluster and All Related Resources |
| delete-load-balancer-forwarding-rule | Delete Forwarding Rule |
| delete-load-balancer | Delete Load Balancer |
| delete-network | Delete a private network |
| delete-nodepool-instance | Delete NodePool Instance |
| delete-nodepool | Delete Nodepool |
| delete-object-storage | Delete Object Storage |
| delete-reserved-ip | Delete Reserved IP |
| delete-snapshot | Delete Snapshot |
| delete-ssh-key | Delete SSH Key |
| delete-startup-script | Delete Startup Script |
| delete-user | Delete User |
| delete-vpc | Delete a VPC |
| detach-block | Detach Block Storage |
| detach-instance-iso | Detach ISO from instance |
| detach-instance-network | Detach Private Network from Instance. |
| detach-instance-vpc | Detach VPC from Instance |
| detach-reserved-ip | Detach Reserved IP |
| get-account | Get Account Info |
| get-backup-information | Get Backup Information |
| get-backup | Get a Backup |
| get-bandwidth-baremetal | Bare Metal Bandwidth |
| get-baremetal | Get Bare Metal |
| get-bare-metals-upgrades | Get Available Bare Metal Upgrades |
| get-bare-metal-userdata | Get Bare Metal User Data |
| get-bare-metal-vnc | Get VNC URL for a Bare Metal |
| get-block | Get Block Storage |
| get-connection-pool | Get Connection Pool |
| get-database-db | Get Logical Database |
| get-database | Get Managed Database |
| get-database-user | Get Database User |
| get-dns-domain-dnssec | Get DNSSec Info |
| get-dns-domain-record | Get Record |
| get-dns-domain | Get DNS Domain |
| get-dns-domain-soa | Get SOA information |
| get-firewall-group-rule | Get Firewall Rule |
| get-firewall-group | Get Firewall Group |
| get-instance-backup-schedule | Get Instance Backup Schedule |
| get-instance-bandwidth | Instance Bandwidth |
| get-instance-ipv4 | List Instance IPv4 Information |
| get-instance-ipv6 | Get Instance IPv6 Information |
| get-instance-iso-status | Get Instance ISO Status |
| get-instance-neighbors | Get Instance neighbors |
| get-instance | Get Instance |
| get-instance-upgrades | Get Available Instance Upgrades |
| get-instance-userdata | Get Instance User Data |
| get-invoice-items | Get Invoice Items |
| get-invoice | Get Invoice |
| get-ipv4-baremetal | Bare Metal IPv4 Addresses |
| get-ipv6-baremetal | Bare Metal IPv6 Addresses |
| get-kubernetes-available-upgrades | Get Kubernetes Available Upgrades |
| get-kubernetes-clusters-config | Get Kubernetes Cluster Kubeconfig |
| get-kubernetes-clusters | Get Kubernetes Cluster |
| get-kubernetes-resources | Get Kubernetes Resources |
| get-kubernetes-versions | Get Kubernetes Versions |
| get-loadbalancer-firewall-rule | Get Firewall Rule |
| get-load-balancer-forwarding-rule | Get Forwarding Rule |
| get-load-balancer | Get Load Balancer |
| get-network | Get a private network |
| get-nodepool | Get NodePool |
| get-nodepools | List NodePools |
| get-object-storage | Get Object Storage |
| get-reserved-ip | Get Reserved IP |
| get-snapshot | Get Snapshot |
| get-ssh-key | Get SSH Key |
| get-startup-script | Get Startup Script |
| get-user | Get User |
| get-vpc | Get a VPC |
| halt-baremetal | Halt Bare Metal |
| halt-baremetals | Halt Bare Metals |
| halt-instance | Halt Instance |
| halt-instances | Halt Instances |
| iso-get | Get ISO |
| list-advanced-options | List Advanced Options |
| list-applications | List Applications |
| list-available-plans-region | List available plans in region |
| list-available-versions | List Available Versions |
| list-backups | List Backups |
| list-baremetals | List Bare Metal Instances |
| list-billing-history | List Billing History |
| list-blocks | List Block storages |
| list-connection-pools | List Connection Pools |
| list-database-dbs | List Logical Databases |
| list-database-plans | List Managed Database Plans |
| list-databases | List Managed Databases |
| list-database-users | List Database Users |
| list-dns-domain-records | List Records |
| list-dns-domains | List DNS Domains |
| list-firewall-group-rules | List Firewall Rules |
| list-firewall-groups | List Firewall Groups |
| list-instance-ipv6-reverse | List Instance IPv6 Reverse |
| list-instance-private-networks | List instance Private Networks |
| list-instances | List Instances |
| list-instance-vpcs | List instance VPCs |
| list-invoices | List Invoices |
| list-isos | List ISOs |
| list-kubernetes-clusters | List all Kubernetes Clusters |
| list-loadbalancer-firewall-rules | List Firewall Rules |
| list-load-balancer-forwarding-rules | List Forwarding Rules |
| list-load-balancers | List Load Balancers |
| list-maintenance-updates | List Maintenance Updates |
| list-metal-plans | List Bare Metal Plans |
| list-networks | List Private Networks |
| list-object-storage-clusters | Get All Clusters |
| list-object-storages | List Object Storages |
| list-os | List OS |
| list-plans | List Plans |
| list-public-isos | List Public ISOs |
| list-regions | List Regions |
| list-reserved-ips | List Reserved IPs |
| list-service-alerts | List Service Alerts |
| list-snapshots | List Snapshots |
| list-ssh-keys | List SSH Keys |
| list-startup-scripts | List Startup Scripts |
| list-users | Get Users |
| list-vpcs | List VPCs |
| patch-reserved-ips-reserved-ip | Update Reserved IP |
| post-firewalls-firewall-group-id-rules | Create Firewall Rules |
| post-instances-instance-id-ipv4-reverse-default | Set Default Reverse DNS Entry |
| put-snapshots-snapshot-id | Update Snapshot |
| reboot-baremetal | Reboot Bare Metal |
| reboot-bare-metals | Reboot Bare Metals |
| reboot-instance | Reboot Instance |
| reboot-instances | Reboot instances |
| recycle-nodepool-instance | Recycle a NodePool Instance |
| regenerate-object-storage-keys | Regenerate Object Storage Keys |
| reinstall-baremetal | Reinstall Bare Metal |
| reinstall-instance | Reinstall Instance |
| restore-instance | Restore Instance |
| start-baremetal | Start Bare Metal |
| start-bare-metals | Start Bare Metals |
| start-instance | Start instance |
| start-instances | Start instances |
| start-kubernetes-cluster-upgrade | Start Kubernetes Cluster Upgrade |
| start-maintenance-updates | Start Maintenance Updates |
| start-version-upgrade | Start Version Upgrade |
| update-advanced-options | Update Advanced Options |
| update-baremetal | Update Bare Metal |
| update-block | Update Block Storage |
| update-connection-pool | Update Connection Pool |
| update-database | Update Managed Database |
| update-database-user | Update Database User |
| update-dns-domain-record | Update Record |
| update-dns-domain | Update a DNS Domain |
| update-dns-domain-soa | Update SOA information |
| update-firewall-group | Update Firewall Group |
| update-instance | Update Instance |
| update-kubernetes-cluster | Update Kubernetes Cluster |
| update-load-balancer | Update Load Balancer |
| update-network | Update a Private Network |
| update-nodepool | Update Nodepool |
| update-object-storage | Update Object Storage |
| update-ssh-key | Update SSH Key |
| update-startup-script | Update Startup Script |
| update-user | Update User |
| update-vpc | Update a VPC |
| view-migration-status | Get Migration Status |
