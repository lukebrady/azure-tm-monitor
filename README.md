# Azure Traffic Manager Monitor

Azure Traffic Manager Monitor is a PowerShell Module that gives you the ability to monitor your
Azure Traffic Manager deployment. You can configure your connection using the azure-tm-config.json file
in the Configuration.

Below is an example of how to use Azure Traffic Manager Monitor:

```powershell
Import-Module azure-tm-monitor

$profile = Get-TrafficManagerProfile -JSONConfiguration # Add a path to your json configuration
$dns = Get-TrafficManagerCurrentEndpoint -Name # Name of the endpoint that needs to be monitored -PriorityEndpoint # Add the priority endpoint
$endpointObj = New-EndpointObject -ProfileObject $profile -DNSObject $dns
$obj = Test-TrafficManagerEndpoint -EndpointObject $endpointObj
New-TrafficMonitorStatusReport -ResultObject $obj -MailAddress {List of mail addresses} -SmtpServer {SMTPServerName}
```