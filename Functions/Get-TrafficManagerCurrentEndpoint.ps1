# Gets the current DNS record that traffic manager is sending to.
function Get-TrafficManagerCurrentEndpoint {
    [CmdletBinding()]
    [Alias()]
    [OutputType([Object])]
    Param (
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$false,
                   Position=0)]
        [String]
        $Name,
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$false,
                   Position=1)]
        [String]
        $PriorityEndpoint
    )
    Process {
        $statusObj = @{}
        $dnsInfo = Resolve-DnsName -Name $Name -ErrorAction Stop
        if($dnsInfo.Name[2] -ne $PriorityEndpoint) {
            $statusObj.Add("CurrentEndpoint", $dnsInfo.Name[2])
            $statusObj.Add("Degraded", $true)
        }
        else {
            $statusObj.Add("CurrentEndpoint", $PriorityEndpoint)
            $statusObj.Add("Degraded", $false)
        }
    }
    End { return $statusObj }
}