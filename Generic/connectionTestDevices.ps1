
#Replace with the IP addresses of your switches for example @("192.168.1.1", "192.168.1.2", "192.168.1.3")
$SwitchIPs = @("192.168.1.2", "192.168.1.3")		
#Replace with the IP address of your router
$RouterIP = "192.168.1.1"
#Path to the log file
$LogFile = Join-Path -Path $PSScriptRoot -ChildPath "\testConnectionLog.log"
#Adjust the interval between pings if needed
$sleepInterval = 5

while ($true) {
    $SwitchResults = @{}
    foreach ($IP in $SwitchIPs) {
        $SwitchResults[$IP] = Test-Connection -ComputerName $IP -Count 1 -Quiet
    }

    $RouterResult = Test-Connection -ComputerName $RouterIP -Count 1 -Quiet

    $DateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "$DateTime - Router: $RouterResult"

    foreach ($IP in $SwitchIPs) {
        $LogEntry += ", Switch ($IP): $($SwitchResults[$IP])"
    }

    if (-not($RouterResult) -or ($SwitchResults.Values -contains $false)) {
        $LogEntry | Out-File -FilePath $LogFile -Append
		write-host $LogEntry
    }else{
		write-host $LogEntry
	}

    Start-Sleep -Seconds $sleepInterval
}