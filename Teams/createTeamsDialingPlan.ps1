
#User Account Credential
$userAccountUPN = "Account UPN"

Install-Module -Name MicrosoftTeams
Connect-MicrosoftTeams

New-CsOnlinePSTNGateway -Fqdn $userAccountUPN -Enabled $true -SipSignalingPort 5062 -MaxConcurrentSessions 100 -ForwardCallHistory $true -ForwardPai $true
Set-CsOnlinePstnUsage -Identity Global -Usage @{add="3CX PSTN Usage"}
Set-CsOnlinePstnUsage -Identity Global -Usage @{remove="All"}

New-CsOnlineVoiceRoute -Identity "3CX Voice Route" -NumberPattern "^((\+\d+)|(\d{2,5})|(\*0\d)|(\*1\d)|(\*1\d\d{3})|(\*20\*)|(\*20\*\d{3})|(\*3[0-4])|(\*4\d{3})|(\*62)|(\*63)|(\*9\d{3})|(\*9\d{3})|((\+)?\d+\*\*\d+)|(\*64[1-2])|(\*5(\+)?\d+)|(\*68\d)|(\*777)$|(\*888))$" -OnlinePstnGatewayList teams.reephamhigh.com -OnlinePstnUsages "3CX PSTN Usage" -Priority 1
Set-CsOnlineVoiceRoute -Identity "3CX Voice Route" -NumberPattern "^((\+\d+)|(\d{2,5})|(\*0\d)|(\*1\d)|(\*1\d\d{3})|(\*20\*)|(\*20\*\d{3})|(\*3[0-4])|(\*4\d{3})|(\*62)|(\*63)|(\*9\d{3})|(\*9\d{3})|((\+)?\d+\*\*\d+)|(\*64[1-2])|(\*5(\+)?\d+)|(\*68\d)|(\*777)$|(\*888))$" -OnlinePstnGatewayList teams.reephamhigh.com -OnlinePstnUsages "3CX PSTN Usage" -Priority 1

New-CsOnlineVoiceRoutingPolicy "3CX Voice Route Policy" -OnlinePstnUsages "3CX PSTN Usage"
New-CsTeamsCallingPolicy -Identity "3CX Calling Policy" -AllowVoicemail "AlwaysDisabled"
New-CsTenantDialPlan -Identity "3CX Dial Plan" -Description "3CX via Direct Routing"

$TCXEmerceny = New-CsVoiceNormalizationRule -Parent Global -Name "3CX Emergency" -Description "Emergency Numbers" -Pattern '^(999|101|111|112)$' -Translation '$1' -IsInternalExtension $false -InMemory
$TCXExt = New-CsVoiceNormalizationRule -Parent Global -Name "3CX Internal" -Description "Internal Calls" -Pattern '^(\d{3})$' -Translation '$1' -IsInternalExtension $false -InMemory
$TCXNational= New-CsVoiceNormalizationRule -Parent Global -Name "3CX National" -Description "National Calls" -Pattern '^0([1-9]{1}\d+)$' -Translation '+44$1'  -IsInternalExtension $false -InMemory
$TCXInterNational= New-CsVoiceNormalizationRule -Parent Global -Name "3CX Inter-National" -Description "International Calls" -Pattern '^00([1-9]{1}\d+)$' -Translation '+$1'  -IsInternalExtension $false -InMemory
	
Set-CsTenantDialPlan -Identity "3CX Dial Plan" -NormalizationRules @{add=$TCXEmerceny}
Set-CsTenantDialPlan -Identity "3CX Dial Plan" -NormalizationRules @{add=$TCXExt}
Set-CsTenantDialPlan -Identity "3CX Dial Plan" -NormalizationRules @{add=$TCXNational}
Set-CsTenantDialPlan -Identity "3CX Dial Plan" -NormalizationRules @{add=$TCXInterNational}

$TCXUnPartAny = New-CsVoiceNormalizationRule -Parent Global -Name "3CX DialCode Unpark Any" -Description "DialCode Unpark Any" -Pattern '^(\*1\d)$' -Translation '$1' -IsInternalExtension $false -InMemory
$TCXUnPartExt = New-CsVoiceNormalizationRule -Parent Global -Name "3CX DialCode Unpark Ext" -Description "DialCode Unpark Extension" -Pattern '^(\*1\d\d{3})$' -Translation '$1' -IsInternalExtension $false -InMemory
$TCXPickUpAny = New-CsVoiceNormalizationRule -Parent Global -Name "3CX DialCode PickUP Any" -Description "DialCode Pickup Any" -Pattern '^(\*20\*)$' -Translation '$1' -IsInternalExtension $false -InMemory
$TCXPickUpExt = New-CsVoiceNormalizationRule -Parent Global -Name "3CX DialCode PickUP Ext" -Description "DialCode Pickup Any" -Pattern '^(\*20\*\d{3})$' -Translation '$1' -IsInternalExtension $false -InMemory
$TCXProfileChange = New-CsVoiceNormalizationRule -Parent Global -Name "3CX DialCode Profile" -Description "DialCode Profile" -Pattern '^(\*3[0-4])$' -Translation '$1' -IsInternalExtension $false -InMemory
$TCXVboxOfUser = New-CsVoiceNormalizationRule -Parent Global -Name "3CX DialCode Vbox Call" -Description "DialCode Vbox of User" -Pattern '^(\*4\d{3})$' -Translation '$1' -IsInternalExtension $false -InMemory
$TCXQueueIn = New-CsVoiceNormalizationRule -Parent Global -Name "3CX DialCode Queue In" -Description "DialCode Queue LogIn" -Pattern '^(\*62)$' -Translation '$1' -IsInternalExtension $false -InMemory
$TCXQueueOut = New-CsVoiceNormalizationRule -Parent Global -Name "3CX DialCode Queue Out" -Description "DialCode Queue LogOut" -Pattern '^(\*63)$' -Translation '$1' -IsInternalExtension $false -InMemory
$TCXPaging = New-CsVoiceNormalizationRule -Parent Global -Name "3CX DialCode Paging" -Description "DialCode Page Ext" -Pattern '^(\*9\d{3})$' -Translation '$1' -IsInternalExtension $false -InMemory
$TCXBilling = New-CsVoiceNormalizationRule -Parent Global -Name "3CX DialCode Billing" -Description "DialCode Billing" -Pattern '^((\+)?\d+\*\*\d+)$' -Translation '$1' -IsInternalExtension $false -InMemory
$TCX3cxStatus = New-CsVoiceNormalizationRule -Parent Global -Name "3CX DialCode Office" -Description "DialCode Office" -Pattern '^(\*64[0-2])$' -Translation '$1' -IsInternalExtension $false -InMemory
$TCXCallerID = New-CsVoiceNormalizationRule -Parent Global -Name "3CX DialCode CallerID" -Description "DialCode Hide CallerID" -Pattern '^(\*5(\+)?\d+)$' -Translation '$1' -IsInternalExtension $false -InMemory
$TCXHotel = New-CsVoiceNormalizationRule -Parent Global -Name "3CX DialCode Hotel" -Description "DialCode Made Codes" -Pattern '^(\*68\d)$' -Translation '$1' -IsInternalExtension $false -InMemory
$TCXEchoTest = New-CsVoiceNormalizationRule -Parent Global -Name "3CX DialCode Echo" -Description "DialCode Echo Test" -Pattern '^(\*777)$' -Translation '$1' -IsInternalExtension $false -InMemory
$TCXCallTest = New-CsVoiceNormalizationRule -Parent Global -Name "3CX DialCode Call" -Description "DialCode Call Test" -Pattern '^(\*888)$' -Translation '$1' -IsInternalExtension $false -InMemory

Set-CsTenantDialPlan -Identity "3CX Dial Plan" -NormalizationRules @{add=$TCXUnPartAny}
Set-CsTenantDialPlan -Identity "3CX Dial Plan" -NormalizationRules @{add=$TCXUnPartExt}
Set-CsTenantDialPlan -Identity "3CX Dial Plan" -NormalizationRules @{add=$TCXPickUpAny}
Set-CsTenantDialPlan -Identity "3CX Dial Plan" -NormalizationRules @{add=$TCXPickUpExt}
Set-CsTenantDialPlan -Identity "3CX Dial Plan" -NormalizationRules @{add=$TCXProfileChange}
Set-CsTenantDialPlan -Identity "3CX Dial Plan" -NormalizationRules @{add=$TCXVboxOfUser}
Set-CsTenantDialPlan -Identity "3CX Dial Plan" -NormalizationRules @{add=$TCXQueueIn}
Set-CsTenantDialPlan -Identity "3CX Dial Plan" -NormalizationRules @{add=$TCXQueueOut}
Set-CsTenantDialPlan -Identity "3CX Dial Plan" -NormalizationRules @{add=$TCXPaging}
Set-CsTenantDialPlan -Identity "3CX Dial Plan" -NormalizationRules @{add=$TCXBilling}
Set-CsTenantDialPlan -Identity "3CX Dial Plan" -NormalizationRules @{add=$TCX3cxStatus}
Set-CsTenantDialPlan -Identity "3CX Dial Plan" -NormalizationRules @{add=$TCXCallerID}
Set-CsTenantDialPlan -Identity "3CX Dial Plan" -NormalizationRules @{add=$TCXHotel}
Set-CsTenantDialPlan -Identity "3CX Dial Plan" -NormalizationRules @{add=$TCXEchoTest}
Set-CsTenantDialPlan -Identity "3CX Dial Plan" -NormalizationRules @{add=$TCXCallTest}

pause