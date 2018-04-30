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