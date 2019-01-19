# Add users by using a csv file
Import-Module ActiveDirectory
$Users_To_Add = Import-Csv "Users.csv"
foreach ($User in $Users_To_Add){
	$GivenName = $User.GivenName
	$Surname = $User.Surname
	$Sam = $User.Sam
	$Password = $User.Password
	$Name = $User.Name
	$UPN = $User.UPN
	$Path = Get-ADOrganizationalUnit -Filter 'Name -like "Test"'
	New-ADUser -GivenName $GivenName -Surname $Surname -Enabled $True -Path $Path -UserPrincipalName $UPN -Name $Name -SamAccountName $Sam -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -force) -PasswordNeverExpires $True
}