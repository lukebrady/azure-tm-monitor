<#
    Azure Traffic Manager Monitor is a PowerShell Module that gives you the ability to monitor your
    Azure Traffic Manager deployment. You can configure your connection using the azure-tm-config.json file
    in the Configuration.
    Written By: Luke Brady
    Questions or Comments? Email me <luke.brady@ung.edu>
    University of North Georgia 2018
#>

. $PSScriptRoot\Functions\Get-TrafficManagerCurrentEndpoint.ps1
. $PSScriptRoot\Functions\Get-TrafficManagerProfile.ps1
. $PSScriptRoot\Functions\New-EndpointObject.ps1
. $PSScriptRoot\Functions\New-TrafficMonitorStatusReport.ps1
. $PSScriptRoot\Functions\Test-TrafficManagerEndpoint.ps1