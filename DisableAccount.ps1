#Disable an Account
Import-Moudle ActiveDirectory
$Account=Read-Host "Account: "
Disable-ADAccount $Account