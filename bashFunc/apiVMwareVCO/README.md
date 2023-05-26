# VeloCloud Orchestrator API v1
## https://developer.vmware.com/apis/1532/velocloud-sdwan-vco-api#api

## Cookie-Based Authentication

The VCO API requires cookie-based authentication to function.
Scripts create sessions by invoking the login/enterpriseLogin method before calling any other APIs.
Session cookies typically expire after a period of 24 hours, but it is recomended to invoke the Logout method to invalidate cookies when finished.

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

# External functions to load
extFunc=(
    "apiVMwareVCO/login_enterprise_login"
    "apiVMwareVCO/enterprise_get_enterprise"
    "apiVMwareVCO/logout"
)

# Load external functions
for func in ${extFunc[@]}; do
    if [[ ! -e "/opt/bashFunc/${func}.sh" ]]; then
        echo "$(basename "${0}"): ${func} not found!"
        exit 1
    else . "/opt/bashFunc/${func}.sh"
    fi || exit 1
done

### Variables ###
vco_auth='{"username":"admin@velocloud.net","password":"'$SECRET'"}'
vco_uri="https://vco.velocloud.net/portal/rest"

# Authenticate enterprise or partner (MSP) user
login_enterprise_login

# Get enterprise
enterprise_get_enterprise

# Logout and invalidate authorization session cookie
logout
```

## Session Authentication Methods

| Function    | Description |
| ----------- | ----------- |
| login_enterprise_login | Authenticate enterprise or partner (MSP) user |
| login_operator_login | Authenticate operator user |
| logout | Logout and invalidate authorization session cookie |

## VeloCloud Orchestrator API Methods

| Function    | Description |
| ----------- | ----------- |
| add_enterprise_operator_configuration | Adds an operator profile to multiple enterprises |
| configuration_clone_and_convert_configuration | Create new segment-based profile from existing network-based profile |
| configuration_clone_configuration | Clone configuration profile |
| configuration_clone_enterprise_template | Clone default enterprise configuration profile |
| configuration_delete_configuration | Delete configuration profile |
| configuration_get_configuration | Get configuration profile |
| configuration_get_configuration_modules | Get configuration profile modules |
| configuration_get_identifiable_applications | Get the applications that are identifiable through DPI. |
| configuration_get_routable_applications | Get first packet routable applications |
| configuration_insert_configuration_module | Create configuration module |
| configuration_update_application_map_content | Refresh Application Map(s) |
| configuration_update_application_map_profiles | Refresh Application Map and push updates to Edges |
| configuration_update_configuration_module | Update configuration module |
| configuration_update_configuration | Update configuration profile |
| create_composite_role_by_enterprise | Create composite role by an Enterprise |
| create_composite_role_by_msp | Create composite role by an MSP |
| create_composite_role_by_operator | Create composite role by an Operator |
| delete_composite_roles_by_enterprise | Delete a composite role |
| delete_composite_roles_by_msp | Delete a composite role |
| delete_composite_roles_by_operator | Delete a composite role |
| disaster_recovery_configure_active_for_replication | Configure current VCO for disaster recovery |
| disaster_recovery_demote_active | Demote current VCO from active to zombie |
| disaster_recovery_get_replication_blob | Get blob needed to configure VCO replication on standby |
| disaster_recovery_get_replication_status | Get disaster recovery status |
| disaster_recovery_prepare_for_standby | Designate current VCO as DR standby candidate |
| disaster_recovery_promote_standby_to_active | Promote standby VCO to active |
| disaster_recovery_remove_standby | Remove VCO disaster recovery on current server |
| disaster_recovery_transition_to_standby | Transition VCO to standby |
| edge_delete_edge_bgp_neighbor_records | Delete Edge BGP neighbor records |
| edge_delete_edge | Delete Edge |
| edge_edge_cancel_reactivation | Cancel pending Edge reactivation request |
| edge_edge_provision | Provision Edge |
| edge_edge_request_reactivation | Prepare Edge for reactivation |
| edge_get_client_visibility_mode | Get an edge's client visibility mode |
| edge_get_edge_configuration_modules | Get effective Edge configuration |
| edge_get_edge_configuration_stack | Get Edge configuration stack |
| edge_get_edge_csr | Get latest edge CSR |
| edge_get_edge | Get Edge |
| edge_get_edge_pending_csrs | Get all edge pending CSRs |
| edge_get_edge_sdwan_peers | Get an edge's SD-WAN peers |
| edge_insert_edge_certificate | Insert edge certificate |
| edge_set_bastion_state | Set the edge bastion state |
| edge_set_edge_enterprise_configuration | Apply configuration profile to Edge |
| edge_set_edge_hand_off_gateways | Set Edge on premise hand-off gateway(s) |
| edge_set_edge_operator_configuration | Apply an Operator Profile to an Edge |
| edge_unset_edge_operator_configuration | Unset an Edge's Operator Profile |
| edge_update_analytics_settings_for_edges | Update Edge Analytics Settings |
| edge_update_edge_admin_password | Update Edge local UI authentication credentials |
| edge_update_edge_attributes | Update Edge attributes |
| edge_update_edge_credentials_by_configuration | Update Edge local UI credentials by configuration profile |
| enterprise_assign_enterprise_operator_configurations | Assigns one or more operator configurations to an enterprise |
| enterprise_clone_enterprise_v2 | Clone an enterprise, owned by the operator or an MSP. |
| enterprise_create_api_token | Create Enterprise API Token |
| enterprise_decode_enterprise_key | Decrypt an enterprise key |
| enterprise_delete_enterprise | Delete enterprise |
| enterprise_delete_enterprise_gateway_records | Delete gateway BGP neighbor record(s) for enterprise |
| enterprise_delete_enterprise_network_allocation | Delete enterprise network allocation |
| enterprise_delete_enterprise_network_segment | Delete an enterprise network segment |
| enterprise_delete_enterprise_service | Delete enterprise network service |
| enterprise_delete_object_group | Delete an enterprise object group |
| enterprise_disable_cluster_for_edge_hub | Unconfigure cluster as a VPN hub |
| enterprise_download_api_token | Download/Generate API Token |
| enterprise_enable_cluster_for_edge_hub | Configure cluster as a VPN hub |
| enterprise_encode_enterprise_key | Encrypt an enterprise key |
| enterprise_generate_nsd_via_edge_service_configuration | Get Enterprise Default Edge Direct Provider Service Data |
| enterprise_get_analytics_configuration | Get enterprise analytics configuration details |
| enterprise_get_api_tokens | Get API Tokens of a network, enterprise or enterprise Proxy |
| enterprise_get_default_operator_configuration | Gets the default operator configration for an enterprise |
| enterprise_get_enterprise_addresses | Get enterprise IP address(es) |
| enterprise_get_enterprise_alert_configurations | Get enterprise alert configuration(s) |
| enterprise_get_enterprise_alert_definitions | Get enterprise alert definitions |
| enterprise_get_enterprise_alerts | Get triggered enterprise alerts |
| enterprise_get_enterprise_all_alert_recipients | Get recipients receiving all enterprise alerts |
| enterprise_get_enterprise_capabilities | Get enterprise capabilities |
| enterprise_get_enterprise_configurations | Get enterprise configuration profiles |
| enterprise_get_enterprise_distributed_cost_calculation | Get distributed cost calculation property for an enterprise |
| enterprise_get_enterprise_edges | Get enterprise Edges |
| enterprise_get_enterprise_gateway_handoff | Get enterprise gateway handoff configuration |
| enterprise_get_enterprise | Get enterprise |
| enterprise_get_enterprise_maximum_segments | Get enterprise maximum segment |
| enterprise_get_enterprise_network_allocation | Get enterprise network allocation |
| enterprise_get_enterprise_network_allocations | Get enterprise network allocations |
| enterprise_get_enterprise_network_segments | Get all network segment objects defined on an enterprise |
| enterprise_get_enterprise_operator_configuration | Get the Operator Profile assigned to an Enterprise |
| enterprise_get_enterprise_property | Get enterprise property |
| enterprise_get_enterprise_rate_limits | Get enterprise rate limits |
| enterprise_get_enterprise_route_configuration | Get enterprise global routing preferences |
| enterprise_get_enterprise_route_table | Get enterprise route table |
| enterprise_get_enterprise_services | Get enterprise network services |
| enterprise_get_enterprises_missinggateway | Gets the list of Enterprises with missing Gateway Type |
| enterprise_get_enterprise_specific_operator_configs | Gets the enterprise assigned operator configurations |
| enterprise_get_enterprises_with_property | Gets all enterprises having a particular property and a value |
| enterprise_get_enterprise_users | Get enterprise users |
| enterprise_get_object_groups | Get enterprise object group(s) |
| enterprise_get_use_nsd_policy | Get Use NSD policy property of an enterprise |
| enterprise_insert_enterprise | Create enterprise |
| enterprise_insert_enterprise_edge_cluster | Insert enterprise edge cluster  |
| enterprise_insert_enterprise_network_allocation | Create enterprise network allocation |
| enterprise_insert_enterprise_network_segment | Create enterprise network segment |
| enterprise_insert_enterprise_service | Create enterprise service |
| enterprise_insert_enterprise_user | Create enterprise user |
| enterprise_insert_object_group | Create enterprise object group |
| enterprise_insert_or_update_analytics_configuration | Inserts/updates analytics configuration of an enterprise |
| enterprise_insert_or_update_enterprise_alert_configurations | Create, update, or delete enterprise alert configurations |
| enterprise_insert_or_update_enterprise_capability | Create or update enterprise capability |
| enterprise_insert_or_update_enterprise_gateway_handoff | Create or update enterprise gateway handoff configuration |
| enterprise_insert_or_update_enterprise_property | Insert or update an enterprise property |
| enterprise_insert_or_update_enterprise_specific_rate_limits | Set enterprise rate limits |
| enterprise_is_enterprise_upgraded_later_than | Checks an enterprise is upgraded to version later than specified version |
| enterprise_proxy_create_api_token | Create API Token |
| enterprise_proxy_delete_enterprise_proxy_user | Delete partner admin user |
| enterprise_proxy_download_api_token | Download/Generate API Token |
| enterprise_proxy_get_api_tokens | Get API Tokens of a network, enterprise or enterprise Proxy |
| enterprise_proxy_get_enterprise_proxy_capabilities | Get partner capabilities |
| enterprise_proxy_get_enterprise_proxy_cloneable_enterprises | Get cloneable enterprises under enterprise proxy  |
| enterprise_proxy_get_enterprise_proxy_edge_inventory | Get partner enterprises and associated Edge inventory |
| enterprise_proxy_get_enterprise_proxy_enterprises | Get partner enterprises |
| enterprise_proxy_get_enterprise_proxy_enterprises_with_property | Gets all MSP enterprises having a particular property and a value |
| enterprise_proxy_get_enterprise_proxy_gateway_pools | Get gateway pools |
| enterprise_proxy_get_enterprise_proxy_gateways | Get gateways for enterprise proxy |
| enterprise_proxy_get_enterprise_proxy | Get enterprise proxy |
| enterprise_proxy_get_enterprise_proxy_operator_profiles | Get partner operator profiles |
| enterprise_proxy_get_enterprise_proxy_property | Get enterprise proxy property |
| enterprise_proxy_get_enterpriseProxy_rate_limits | Get enterpriseProxy rate limits |
| enterprise_proxy_get_enterprise_proxy_user | Get enterprise proxy user |
| enterprise_proxy_get_enterprise_proxy_users | Get enterprise proxy admin users |
| enterprise_proxy_insert_enterprise_proxy_enterprise | Create enterprise owned by MSP |
| enterprise_proxy_insert_enterprise_proxy_user | Create partner admin user |
| enterprise_proxy_insert_or_update_enterprise_proxy_capability | Create or update partner capability |
| enterprise_proxy_insert_or_update_enterprise_proxy_property | Insert or update an enterprise proxy (MSP) property |
| enterprise_proxy_insert_or_update_enterprise_specific_rate_limits | Set enterprise proxy rate limits |
| enterprise_proxy_revoke_api_token | Revoke an API Token |
| enterprise_proxy_update_enterprise_proxy_user | Update enterprise proxy admin user |
| enterprise_refresh_api_token | Refresh an API Token |
| enterprise_revoke_api_token | Revoke an API Token |
| enterprise_set_bastion_state | Set the enterprise bastion state |
| enterprise_set_enterprise_all_alert_recipients | Specify recipients for all enterprise alerts |
| enterprise_set_enterprise_distributed_cost_calculation | Set distributed cost calculation for an enterprise. |
| enterprise_set_enterprise_maximum_segments | Set enterprise maximum segments |
| enterprise_set_enterprise_operator_configuration | Apply operator profile to given enterprise |
| enterprise_set_enterprise_refresh_routes_version | Set refresh routes version to latest |
| enterprise_set_nsd_buckets_flag | Set NSDBuckets flag for an enterprise. |
| enterprise_update_edge_image_management_multiple | Updates manage software image feature for multiple customers |
| enterprise_update_edge_image_management | Updates manage software image feature for a customer |
| enterprise_update_enterprise_edge_cluster | Update enterprise edge cluster  |
| enterprise_update_enterprise_network_allocation | Update enterprise network allocation |
| enterprise_update_enterprise_network_segment | Update an enterprise network segment |
| enterprise_update_enterprise_route_configuration | Update enterprise global routing preferences |
| enterprise_update_enterprise_route | Update preferred VPN exits for a route |
| enterprise_update_enterprise_security_policy | Update enterprise security policy |
| enterprise_update_enterprise_service | Update enterprise network service |
| enterprise_update_enterprise | Update enterprise |
| enterprise_update_nsd_bgp_configuration | Update NSD BGP configuration for the specified enterprise |
| enterprise_update_object_group | Update an enterprise object group |
| enterprise_user_delete_enterprise_user | Delete enterprise user |
| enterprise_user_get_api_tokens | Get API Tokens owned by current user |
| enterprise_user_get_enterprise_user | Get enterprise user |
| enterprise_user_update_enterprise_user | Update enterprise user |
| event_get_enterprise_events | Get Edge events |
| event_get_operator_events | Get operator events |
| event_get_proxy_events | Fetch Partner events |
| firewall_get_enterprise_firewall_logs | Get enterprise firewall logs |
| firmware_image_get_image_update_list | Get image lists |
| gateway_delete_gateway | Delete a gateway |
| gateway_gateway_provision | Provision gateway |
| gateway_get_gateway_csr | Get latest gateway CSR |
| gateway_get_gateway_edge_assignments | Get edge assignments for a gateway |
| gateway_get_gateway_pending_csrs | Get all gateway pending CSRs |
| gateway_insert_gateway_certificate | Insert gateway certificate |
| gateway_pool_add_gateway_pool_gateway | Add Gateway Pool Gateway |
| gateway_pool_remove_gateway_pool_gateway | Remove Gateway Pool Gateway |
| gateway_property_delete_replacement_gateway_property | Delete replacement gateway property |
| gateway_property_get_gateway_properties | Get gateway properties |
| gateway_set_bastion_state | Set the gateway bastion state |
| gateway_update_gateway_attributes | Update gateway attributes |
| generate_ssh_key | Generate users ssh key |
| get_composite_roles_by_enterprise | Get composite roles by an Enterprise |
| get_composite_roles_by_msp | Get composite roles by an Msp |
| get_composite_roles_by_operator | Get composite roles by operator |
| get_functional_roles_by_enterprise | Get functional roles by an Enterprise |
| get_functional_roles_by_msp | Get functional roles by an Msp |
| get_functional_roles_by_operator | Get functional roles by an Operator |
| get_role_customization_privileges | Get privileges for roles in a Role Customization Package |
| image_get_image_update_list | Get image lists |
| import_ssh_key | Import users ssh key |
| link_quality_event_get_link_quality_events | Get link quality (QoE) scores for an Edge |
| link_update_link_attributes | Update WAN link |
| metrics_get_edge_app_link_metrics | Get flow metric aggregate data |
| metrics_get_edge_app_link_series | Get flow metric time series data |
| metrics_get_edge_app_metrics | Get flow metric aggregate data by application |
| metrics_get_edge_app_series | Get flow metric time series data by application |
| metrics_get_edge_category_metrics | Get flow metric aggregate data by application category |
| metrics_get_edge_category_series | Get flow metric time series data by application category |
| metrics_get_edge_dest_metrics | Get flow metric aggregate data by destination |
| metrics_get_edge_dest_series | Get flow metric time series data by destination |
| metrics_get_edge_device_metrics | Get flow metric aggregate data by client device |
| metrics_get_edge_device_series | Get flow metric time series data by client device |
| metrics_get_edge_flow_visibility_metrics | Get flow stats metric data for a given edge |
| metrics_get_edge_link_metrics | Get summary link metrics for an Edge |
| metrics_get_edge_link_series | Get link metric time series data for an Edge |
| metrics_get_edge_os_metrics | Get flow metric aggregate data by client OS |
| metrics_get_edge_os_series | Get flow metric time series data by client OS |
| metrics_get_edge_sdwan_peer_path_metrics | Get path stats metric aggregate data for a given edge and SD-WAN peer pair |
| metrics_get_edge_sdwan_peer_path_series | Get path stats metric time series data for a given edge and SD-WAN peer pair |
| metrics_get_edge_segment_metrics | Get flow metric aggregate data by segment Id |
| metrics_get_edge_segment_series | Get flow metric time series data by segment id |
| metrics_get_edge_status_metrics | Get Edge healthStats metrics for an interval |
| metrics_get_edge_status_series | Get Edge healthStats time series for an interval  |
| metrics_get_enterprise_flow_metrics | Get flow metric aggregate data by specified flow dimension |
| metrics_get_gateway_status_metrics | Get Gateway health metric summaries for an interval |
| metrics_get_gateway_status_series | Get Gateway health metric time series for an interval |
| migration_get_enterprises_using_quiesced_gateways | Gets a list of enterpriseIds using quiesced gateways |
| migration_get_migration_actions | Get migration actions from migration entity records filtered by enterpriseId,edgeId,gatewayId ,enterpriseObjectId or type |
| migration_get_migration_gateways | Get NSD migration gateways |
| migration_verify_nsd_tunnels | Verify NSD tunnels and transition the state of migration action |
| monitoring_get_aggregate_edge_link_metrics | Get aggregate Edge link metrics across enterprises |
| monitoring_get_aggregate_enterprise_events | Get events across all enterprises |
| monitoring_get_aggregates | Get aggregate enterprise and Edge information |
| monitoring_get_enterprise_bgp_peer_status | Get gateway BGP peer status for all enterprise gateways |
| monitoring_get_enterprise_edge_bfd_peer_status | Get Edge BFD peer status for all enterprise Edges |
| monitoring_get_enterprise_edge_bgp_peer_status | Get Edge BGP peer status for all enterprise Edges |
| monitoring_get_enterprise_edge_cluster_status | Get Edge Cluster status |
| monitoring_get_enterprise_edge_link_status | Get Edge and link status data |
| monitoring_get_enterprise_edge_nvs_tunnel_status | Get state history for tunnels from Edge(s) to non-SD-WAN sites |
| monitoring_get_enterprise_edge_status | Get Enterprise Edge monitoring status |
| monitoring_get_network_gateway_status | Get Network Gateway monitoring status |
| monitoring_get_vpn_edge_action_status | Gets the VPN edge action status for automated deployments |
| monitoring_get_vpn_site_status | Gets the VPN site status for automated deployments |
| network_create_api_token | Create Operator API Token |
| network_delete_network_gateway_pool | Delete gateway pool |
| network_download_api_token | Download/Generate Operator API Token |
| network_get_api_tokens | Get API Tokens of a network |
| network_get_eligible_replacement_gateways | Get a list of gateways similar to a particular gateway for roles and pool assignments.If roles(unsaved roles) are passed in the request ,replacement gateway will be matched with these roles and filtered |
| network_get_network_cloneable_enterprises | Get enterprises on network |
| network_get_network_configurations | Get operator configuration profiles |
| network_get_network_enterprises | Get enterprises on network |
| network_get_network_gateway_pools | Get gateway pools on network |
| network_get_network_gateways | Get gateways on network |
| network_get_network_operator_users | Get operator users for network |
| network_insert_network_gateway_pool | Create gateway pool |
| network_refresh_api_token | Refresh an API Token |
| network_remove_operator_config_assoc_from_all_enterprises | Removes operator configuration association from all enterprises |
| network_revoke_api_token | Revoke an Operator API Token |
| network_set_replacement_gateway | Insert/Update replacement gateway |
| network_update_network_gateway_pool_attributes | Update gateway pool attributes |
| operator_user_delete_operator_user | Delete operator user |
| operator_user_get_api_tokens | Get API Tokens owned by current user |
| operator_user_get_operator_user | Get operator user |
| operator_user_insert_operator_user | Create operator user |
| operator_user_set_bastion_state | Set the operatorUser bastion state |
| operator_user_update_operator_user | Update operator user |
| pki_get_current_revoked_certificates | Get revoked edge and gateway certificates |
| role_apply_role_customization_package | Apply Role Customization Package |
| role_create_role_customization | Create role customization |
| role_delete_role_customization | Delete role customization |
| role_get_eligible_privileges_for_customization | Gets list of privileges that are eligible for customization |
| role_get_role_customizations | Gets role customizations at the given level (NETWORK, PARTNER, ENTERPRISE or ALL) in VCO |
| role_get_user_type_roles | Get roles per user type |
| role_insert_role_customization_package | Inserts Role Customization Package |
| role_remove_custom_roles | Removes role customizations at the given level (NETWORK, PARTNER, ENTERPRISE or ALL) in VCO |
| role_remove_enterprise_custom_roles | Removes role customizations at ENTERPRISE level |
| role_remove_enterprise_proxy_custom_roles | Removes role customizations at PARTNER level |
| role_save_n_apply_role_customization_package | Update and Apply Role Customization Package |
| role_set_enterprise_delegated_to_enterprise_proxy | Grant enterprise access to partner |
| role_set_enterprise_delegated_to_operator | Grant enterprise access to network operator |
| role_set_enterprise_proxy_delegated_to_operator | Grant enterprise proxy access to network operator |
| role_set_enterprise_user_management_delegated_to_operator | Grant enterprise user access to network operator |
| role_set_enterprise_view_sensitive_data_delegated_to_enterprise_proxy | Grant enterprise view sensitive data access to enterprise proxy |
| role_set_enterprise_view_sensitive_data_delegated_to_operator | Grant enterprise view sensitive data access to network operator |
| secure_edge_access_mode | Insert or Update  Secure Edge Access Mode |
| set_client_device_host_name | Set hostname for client device |
| set_default_enterprise_operator_configuration | Makes a particular operator profile, the default for an enterprise |
| sshConfig_get_enterprise_proxy_user_ssh_key | Get SSH Keys |
| sshConfig_get_enterprise_user_ssh_key | Get SSH Keys |
| sshConfig_get_operator_user_ssh_key | Get operator users SSH Keys |
| sshConfig_revoke_enterprise_proxy_user_ssh_key | Revoke enterprise proxy users SSH Keys |
| sshConfig_revoke_enterprise_user_ssh_key | Revoke enterprise users SSH Keys |
| sshConfig_revoke_operator_user_ssh_key | Revoke operator users SSH Keys |
| system_get_version_info | Get system version information |
| system_property_get_system_properties | Get all system properties |
| system_property_get_system_property | Get system property |
| system_property_insert_or_update_system_property | Create or update system property |
| system_property_insert_system_property | Create system property |
| system_property_update_system_property | Update system property |
| update_composite_role_by_enterprise | Updates a composite role by an enterprise |
| update_composite_role_by_msp | Updates a composite role by an Msp |
| update_composite_role_by_operator | Updates a composite role by an Operator |
| vco_diagnostics_get_vco_db_diagnostics | Get VCO Database Diagnostics |
| vco_inventory_associate_edges | Associate Edge inventory from Maestro |
| vco_inventory_associate_existing_edge | Associate existing logical Edge with inventory Edge |
| vco_inventory_delete_rma_inventory_items | Delete RMAed inventory Edges |
| vco_inventory_get_pending_inventory | Get pending Edge inventory from Maestro |
| vco_inventory_push_activation_sign_up | Sign-up form to verify push activation info on Maestro |
| vco_inventory_reassign_inventory_items | Partner edge reassignment |
| vco_inventory_unassign_edges | Unassign Edge inventory |
| vpn_generate_vpn_gateway_configuration | Provision a non-SD-WAN VPN site |
