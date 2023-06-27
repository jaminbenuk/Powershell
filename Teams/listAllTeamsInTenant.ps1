Connect-MicrosoftTeams -AccountId #Add Your UPN

[string]$CSV_Name = "userAccounts.csv"

[string]$workingDirectory = Split-Path $MyInvocation.MyCommand.Path
[string]$CSV_Path = $workingDirectory + "\" + $CSV_Name

$importedUsers = import-csv $CSV_Path
$AllTeams = @()
$TeamList = @()

$importedUsers | Foreach-Object {

	$Username = $_.Username
	$EmailAddress = $_.EmailAddress
	
	write-host "Getting Team Object For: "$Username
	
	$AllTeams += Get-Team -user $EmailAddress

	}
	
write-host "`n`nGathering Team Data For Above" $AllTeams.length " Objects`n`n"

Foreach ($Team in $AllTeams)
	{
		$TeamName = $Team.DisplayName
		$TeamGUID = $Team.GroupId
		$Archived = $Team.Archived
		$TeamOwner = (Get-TeamUser -GroupId $TeamGUID | ?{$_.Role -eq 'Owner'}).Name

		#Don't really need to know members but if we did
		#$TeamMember = (Get-TeamUser -GroupId $TeamGUID | ?{$_.Role -eq 'Member'}).Name

		$TeamList = $TeamList + [PSCustomObject]@{TeamName = $TeamName; TeamGUID = $TeamGUID; Archived = $Archived; TeamOwner = $TeamOwner -join ', '}
	}

$TeamList | export-csv D:\Powershell\Teams\TeamsData.csv -NoTypeInformation

Write-Host "`n`nPress any key to close...`n`n" -ForegroundColor Blue
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")