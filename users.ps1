function Get-RandomCharacters($length, $characters) {
    $random = 1..$length | ForEach-Object { Get-Random -Maximum $characters.length }
    $private:ofs=""
    return [String]$characters[$random]
}
 
function Scramble-String([string]$inputString){     
    $characterArray = $inputString.ToCharArray()   
    $scrambledStringArray = $characterArray | Get-Random -Count $characterArray.Length     
    $outputString = -join $scrambledStringArray
    return $outputString 
}

# Add users by using a csv file
Import-Module ActiveDirectory
$headers = (Get-Content "Users.csv" | Select-Object -First 1).Split(",")
$Users_To_Add = Import-Csv "Users.csv"
foreach ($User in $Users_To_Add){
	if($headers -contains "Password"){
		$Password = $User.Password
	}
	else{
		#10 character password
		$Password = Get-RandomCharacters -length 5 -characters 'abcdefghiklmnoprstuvwxyz'
		$Password += Get-RandomCharacters -length 2 -characters 'ABCDEFGHKLMNOPRSTUVWXYZ'
		$Password += Get-RandomCharacters -length 1 -characters '1234567890'
		$Password += Get-RandomCharacters -length 2 -characters '!"$%&()=?}][{@#*+'
		$Password = Scramble-String($Password)
	}	
	if($headers -contains "GivenName" -and $headers -contains "Surname"){
		$GivenName = $User.GivenName
		$Surname = $User.Surname
	}
	if($headers -contains "Name"){
		$Name = $User.Name
		$Name_Parts = $Name.Split(" ")
		if(!($headers -contains "GivenName") -and !($headers -contains "Surname")){
			if($Name_Parts.length -eq 3){
				$GivenName = $Name_Parts[0]
				$Initials = $Name_Parts[1]
				$Surname = $Name_Parts[2]
			}
			else{
				$GivenName = $Name_Parts[0]
				$Surname = $Name_Parts[1]
			}
		}
	}
	else{
		$Name = "$GivenName $Surname"
		$Name_Parts = $Name.Split(" ")
	}
	#This is the username
	if($headers -contains "SAM"){
		$SAM = $User.SAM
	}
	else{
		if($Name_Parts.length -eq 3){
			$SAM = ($GivenName[0]+$Name_Parts[1][0]+$Surname).toLower()
		}
		else{
			$SAM = ($GivenName[0]+$Surname).toLower()
		}
		#Only works for 2 identical improvement can be made
		$User_Exist = Get-ADUser -Filter 'SamAccountName -like $SAM'
		if($User_Exist){
			$SAM += "2"
			$Name += "2"
		}
	}
	#This looks like something@example.com
	if($headers -contains "UPN"){
		$UPN = $User.UPN
	}
	else{
		#Only works if hostname like computername.example.com
		$FQDN = ([System.Net.Dns]::GetHostByName($env:computerName).HostName).Split(".")
		$UPN = $SAM+"@"+$FQDN[1]+"."+$FQDN[2]
	}
	#Uncomment if the User corresponds to an specific OU
	#$Path = Get-ADOrganizationalUnit -Filter 'Name -like $OU'
	#New-ADUser -GivenName $GivenName -Surname $Surname -Enabled $True -Path $Path -UserPrincipalName $UPN -Name $Name -SamAccountName $Sam -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -force) -PasswordNeverExpires $True
	New-ADUser -GivenName $GivenName -Surname $Surname -Initials $Initials -Enabled $True -UserPrincipalName $UPN -Name $Name -SamAccountName $Sam -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -force) -PasswordNeverExpires $True
	#Dump user creds (risky)
	Add-Content C:\Users\Administrator\Desktop\Users.txt "$SAM $Password"
}