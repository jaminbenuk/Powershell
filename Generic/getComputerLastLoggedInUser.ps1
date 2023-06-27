#----------------------------------------------
# Creatation Date: 02/03/2013
# Edited Date: 04/03/2013
# Created By: Jaminben
# Version: 1.03
#----------------------------------------------

[string]$workingDirectory = Split-Path $MyInvocation.MyCommand.Path
[string]$outFile = $workingDirectory + "\Computer_Users.csv"
[int]$limitResults = 0

Write-Host "Created By: Jaminben`nVersion: 1.03"
$computerName = read-host "`n`nEnter Computer Name"
$limitResults = read-host "`nEnter Number Of Results To Display"

Function getUsers {
	$UserProperty = @{n="User";e={(New-Object System.Security.Principal.SecurityIdentifier $_.ReplacementStrings[1]).Translate([System.Security.Principal.NTAccount])}}
	$TypeProperty = @{n="Action";e={if($_.EventID -eq 7001) {"Logon"} else {"Logoff"}}}
	$TimeProperty = @{n="Time";e={$_.TimeGenerated}}
	
	$netLogs = Get-EventLog -newest $limitResults System -Source Microsoft-Windows-Winlogon -ComputerName $computerName | select $UserProperty, $TypeProperty, $TimeProperty
	$netLogs.GetEnumerator() | Sort-Object Time -descending | Export-Csv $outFile -NoTypeInformation
	$netLogs.GetEnumerator() | Sort-Object Time -descending | Format-Table -autosize
	}

Function checkConection {
	param($InputObject = $null)

	BEGIN {$status = $False}

	PROCESS {
	if((Test-Connection $InputObject -Quiet -count 1)) {
		$status = $True
		}else{
		$status = $False
		}
	}

    END {return $status}
}

Function validName{
if (checkConection $computerName) {
	Write-Host "`nResponse OK" -ForegroundColor DarkGreen
	Write-Host "`nGathering EventLog Information..."
	Write-Host "`nPlease Wait A Moment...`n"
	getUsers
	}else{
	Write-Host "`nResponse failed - Host Not Found" -ForegroundColor red
	}
}

if ($computerName -eq [string]::empty -or $limitResults -eq [string]::empty){
	Write-Host "`nYou've Entered An Invalid Value" -ForegroundColor red
	}else{
	validName
}

Write-Host "`n`nFinished..."
Write-Host "`nPress any key to quit..."

$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")