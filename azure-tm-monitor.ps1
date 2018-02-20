# Get-TrafficManagerProfile creates a new API profile that will be used throughout the rest of the program.
# This is just an object that holds the endpoint properties of a Traffic Manager Profile.
function Get-TrafficManagerProfile {
    [CmdletBinding()]
    [Alias()]
    [OutputType([object])]
    Param (
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [String]
        $JSONConfiguration
    )
    Process {
        $configuration = Get-Content -Path $JSONConfiguration | ConvertFrom-Json -ErrorAction Stop
        $auth = Invoke-RestMethod -Method Post https://login.microsoftonline.com/$($configuration.subscription)/oauth2/token -Body @{"grant_type"="client_credentials";"client_id"=$configuration.client_id;"client_secret"=$configuration.client_secret;"resource"="https://management.core.windows.net/"}
        $uri = "https://management.azure.com/subscriptions/$($Configuration.subscription_id)/resourceGroups/$($Configuration.resource_group)/providers/Microsoft.Network/trafficmanagerprofiles/$($Configuration.traffic_manager_profile)?api-version=2017-05-01"
        $header = @{"Content-Type" = "application/json"; "Authorization" = "Bearer" + " " + $auth.access_token}
        try {
            $tmProfile = Invoke-RestMethod -Method Get -Uri $uri -Headers $header
        } catch {
            Write-Host "Error: Could not get Azure API data."
        }
        $tmObject = $tmProfile.properties.endpoints.properties
        
    }
    End { return $tmObject }
}

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

function New-TrafficMonitorStatusReport {
    [CmdletBinding()]
    [Alias()]
    [OutputType()]
    Param (
        # Result of the Test-TrafficManagerEndpoint function that will be used
        # to determine if people should be alerted.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [Object]
        $ResultObject,
        # Address to send notification to.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [String[]]
        $MailAddress,
	[String]
	$SmtpServer
    )
    Process {
        # A basic message that will be sent out if fail-over has occurr ed.
        $message = "<p>Azure Traffic Manager is now sending traffic to $($ResultObject.CurrentEndpoint).</p>"
        $message += "<p>The priority endpoint is $($ResultObject.PriorityEndpoint).</p>"

        if($ResultObject.FailedOver -eq $true) {
            Send-MailMessage -BodyAsHtml:$true -From azure-tm@ung.edu `
                                               -To $MailAddress `
                                               -Body $message `
                                               -SmtpServer $SmtpServer `
                                               -Subject "Azure Traffic Manager Notification" `
                                               -ErrorAction Stop
         }
    }
}


$profile = Get-TrafficManagerProfile -JSONConfiguration # Add a path to your json configuration
$profile
$dns = Get-TrafficManagerCurrentEndpoint -Name # Name of the endpoint that needs to be monitored -PriorityEndpoint # Add the priority endpoint
$endpointObj = New-EndpointObject -ProfileObject $profile -DNSObject $dns
$obj = Test-TrafficManagerEndpoint -EndpointObject $endpointObj
$endpointObj.DNS
#New-TrafficMonitorStatusReport -ResultObject $obj -MailAddress {List of mail addresses} -SmtpServer {SMTPServerName}
