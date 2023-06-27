
#New password for all accounts located in the $OuPath
$passwordString = "Password"

Import-Module ActiveDirectory

$OuPath = "OU=SomeOU,OU=SomeOU,DC=some_site,DC=local"

Get-ADUser -Filter * -SearchScope Subtree -SearchBase $OuPath | set-aduser -ChangePasswordAtLogon $True

Get-ADUser -Filter * -SearchScope Subtree -SearchBase $OuPath | Set-ADAccountPassword -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $passwordString -Force)

Write-Host "`n`nPress any key to continue ..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")