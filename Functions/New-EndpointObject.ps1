function New-EndpointObject {
    [CmdletBinding()]
    [Alias()]
    [OutputType([Object])]
    Param (
        # ProfileObject contains your Traffic Manager profile information.
        [Parameter(Mandatory=$true)]
        [Object]
        $ProfileObject,

        # DNSObject contains your current DNS information.
        [Parameter(Mandatory=$true)]
        [Object]
        $DNSObject
    )
    Process {
        $endpointObj = @{
            Profile = $ProfileObject;
            DNS = $DNSObject
        }
    }
    End { return $endpointObj } 
}
