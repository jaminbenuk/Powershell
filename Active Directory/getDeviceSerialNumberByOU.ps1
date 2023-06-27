#----------------------------------------------
# Creatation Date: 16/05/2019
# Edited Date: 16/05/2019
# Created By: Jaminben
# Version: 1.00
#----------------------------------------------

#Add path to OU which you want to search for computer names
$searchOUString = "OU=SomeOU,DC=SomeDomain,DC=local"

#Do not alter code below

Import-Module ActiveDirectory

$Computers = Get-ADComputer -Filter * -SearchBase $searchOUString -Property Name,Description | Select -Property Name,Description

Function descriptionContainsSerialNumber{

	$ComputerDescription = $computer.Description
	
	if (-not ([string]::IsNullOrEmpty($ComputerDescription))) {
	
		Write-Host "AD description is not empty - Checking for SN:" -ForegroundColor DarkGreen

		if ($ComputerDescription -Match "SN:"){
			Write-Host "Skipping - Found SN: so assuming serial number already exists`n" -ForegroundColor DarkGreen
		}else{
			Write-Host "SN: doesn't exist - writing serial number to AD`n" -ForegroundColor red
			$result = Get-WmiObject -ComputerName $computer.Name -Class Win32_BIOS | Select -Property SerialNumber
			$sn = $ComputerDescription+" - SN: "+$result.SerialNumber
			Set-ADComputer $computer.Name -Description $sn
		}
		
	}else{
		Write-Host "AD description is empty - Writing serial number to AD`n" -ForegroundColor red
		
		$result = Get-WmiObject -ComputerName $computer.Name -Class Win32_BIOS | Select -Property SerialNumber
		$sn = "SN: "+$result.SerialNumber
		Set-ADComputer $computer.Name -Description $sn
	}
	
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

Function isComputerOn{
	if (checkConection $Computer.Name) {
		Write-Host $Computer.Name "Response OK - Continuing" -ForegroundColor DarkGreen
		descriptionContainsSerialNumber
	}else{
		Write-Host $Computer.Name "Response failed - Ignoring"`n -ForegroundColor red
	}
}


Foreach ($Computer in $Computers) {
	isComputerOn
}

Write-Host "`n`nPress any key to close..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")