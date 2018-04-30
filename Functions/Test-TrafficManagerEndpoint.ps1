# Test-TrafficManagerEndpoint tests to see if traffic manager has successfully failed
# over traffic and then alerts you on this change so you can investigate the issue.
function Test-TrafficManagerEndpoint {
    [CmdletBinding()]
    [Alias()]
    [OutputType()]
    Param (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [Object]
        $EndpointObject
    )
    Process {
        $result = @{}
        # This is an iteration 1 test that can and will be improved in the future.
        # The test simply loops through the providers list and determines which target
        # is set to priority 1 and the compared the status to the DNS information
        # within the DNSObject.
        foreach($endpoint in $EndpointObject.Profile) {
            if($endpoint.priority -eq 1) {
                $status = $endpoint.endpointMonitorStatus
                $result.Add("PriorityEndpoint",$endpoint.target)
                if($status -eq "Offline" -or $status -eq "Disabled" -or $status -eq "Inactive" -or $status -eq "Degraded") {
                    $result.Add("Online",$false)
                    # If false, test to see if DNS has switched over.
                    if($EndpointObject.DNS.CurrentEndpoint -ne $endpoint.target) {
                        $result.Add("FailedOver",$true)
                        $result.Add("CurrentEndpoint",$EndpointObject.DNS.CurrentEndpoint)
                    }
                    else {
                        $result.Add("FailedOver",$false)
                        $result.Add("CurrentEndpoint",$EndpointObject.DNS.CurrentEndpoint)
                    }
                }
                elseif($status -eq "Online" -or $status -eq "CheckingEndpoint") {
                    $result.Add("Online",$true)
                    $result.Add("FailedOver",$null)
                    $result.Add("CurrentEndpoint", $EndpointObject.DNS.CurrentEndpoint)
                }
            }
        }
    }
    End { return $result }
}