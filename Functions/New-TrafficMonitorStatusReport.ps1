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