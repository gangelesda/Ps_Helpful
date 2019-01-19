#Remove Users given the Account
Import-Module ActiveDirectory
$Account = Read-Host "Account: "
Remove-ADuser $Account