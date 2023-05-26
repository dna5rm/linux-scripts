# VMware SD-WAN Orchestration API v2
## https://developer.vmware.com/apis/vmware-sase-platform/vmware-sdwan/latest/

These API's need to call the APIv1 (apiVMwareVCO) to login and fetch the auth cookie and enterpriseLogicalId.

## VMware SD-WAN Orchestration API v2 Methods

| Function    | Description |
| ----------- | ----------- |
| createEdge | Provision a new Edge, or invoke an action on a set of existing Edges.    |
| createEnterprise | Create a Customer    |
| deleteEdge | Delete an Edge device    |
| deleteEnterprise | Delete a Customer    |
| getApplicationMapApplicationClasses | Fetch application map classes    |
| getApplicationMapApplication | [OPERATOR ONLY] Fetch an application definition for the target application map    |
| getApplicationMapApplications | [OPERATOR ONLY] List applications associated with an application map    |
| getApplicationMap | [OPERATOR ONLY] Fetch application map resource    |
| getEdgeApplication | Fetch edge applications    |
| getEdgeApplications | Fetch edge applications    |
| getEdgeFlowMetrics | Fetch Edge flow stats    |
| getEdgeFlowSeries | Fetch edge flow stats series    |
| getEdgeHealthMetrics | Fetch edge system resource metrics    |
| getEdgeHealthSeries | Fetch system resource metric time series data    |
| getEdgeLinkMetrics | Edge WAN link transport metrics    |
| getEdgeLinkQualityEvents | Fetch link quality scores for an Edge    |
| getEdgeLinkQualitySeries | Fetch link quality timeseries for an Edge    |
| getEdgeLinkSeries | Fetch edge linkStats time series    |
| getEdgeNonSdwanTunnelStatusViaEdge | Fetch Edge non-SD-WAN tunnel status    |
| getEdgePathMetrics | Fetch path stats metrics from an edge    |
| getEdgePathSeries | Fetch path stats time series from an edge    |
| getEdgeProfileDeviceSettings | Edge-specific device settings module response spec    |
| getEnterpriseAggregateHealthStats | Fetch aggregate Edge health metrics for all Edges belonging to the target customer    |
| getEnterpriseAlerts | Fetch past triggered alerts for the specified enterprise    |
| getEnterpriseApplicationById | Fetch enterprise applications    |
| getEnterpriseApplications | Fetch enterprise applications    |
| getEnterpriseBgpSessions | Get BGP peering session state    |
| getEnterpriseClientDevice | Fetch a client device    |
| getEnterpriseClientDevices | Fetch all client devices    |
| getEnterpriseEdge | Get an Edge    |
| getEnterpriseEdges | List Customer Edges    |
| getEnterpriseEvents | Fetch time-ordered list of events    |
| getEnterprise | Fetch a customer    |
| getEnterpriseFlowMetrics | Fetch Customer-global network flow summary statistics    |
| getEnterpriseLinkMetrics | Fetch aggregate WAN link transport metrics for all Customer links    |
| getEnterpriseNonSdwanTunnelStatusViaEdge | Fetch nonSDWAN service status    |
| getEnterpriseProfileDeviceSettings | Profile deviceSettings module response spec    |
| getEnterprises | List Customers    |
| getNonSdwanTunnelsViaGateway | Fetch Non-SD-WAN Sites connected via a Gateway    |
| replaceEdgeProfileDeviceSettings | Edge-specific device settings module replace spec   Note: By default this API operation executes asynchronously, meaning successful requests to this method will return an HTTP 202 response including tracking resource information (incl. an HTTP Location header with a value like `/api/sdwan/v2/asyncOperations/4f951593-aff8-4f3c-9855-10fa5d32a419`). Due to a limitation of our documentation automation/tooling, we can only describe non-async API behavior, we are working on this and will update the expected behavior soon |
| replaceEnterpriseProfileDeviceSettings | Profile deviceSettings module replace spec   Note: By default this API operation executes asynchronously, meaning successful requests to this method will return an HTTP 202 response including tracking resource information (incl. an HTTP Location header with a value like `/api/sdwan/v2/asyncOperations/4f951593-aff8-4f3c-9855-10fa5d32a419`). Due to a limitation of our documentation automation/tooling, we can only describe non-async API behavior, we are working on this and will update the expected behavior soon |
| updateEdgeProfileDeviceSettings | Edge-specific device settings module update spec   Note: By default this API operation executes asynchronously, meaning successful requests to this method will return an HTTP 202 response including tracking resource information (incl. an HTTP Location header with a value like `/api/sdwan/v2/asyncOperations/4f951593-aff8-4f3c-9855-10fa5d32a419`). Due to a limitation of our documentation automation/tooling, we can only describe non-async API behavior, we are working on this and will update the expected behavior soon |
| updateEdge | Update an Edge    |
| updateEnterpriseProfileDeviceSettings | Profile deviceSettings module update spec   Note: By default this API operation executes asynchronously, meaning successful requests to this method will return an HTTP 202 response including tracking resource information (incl. an HTTP Location header with a value like `/api/sdwan/v2/asyncOperations/4f951593-aff8-4f3c-9855-10fa5d32a419`). Due to a limitation of our documentation automation/tooling, we can only describe non-async API behavior, we are working on this and will update the expected behavior soon |
