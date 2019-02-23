Import-Module ActiveDirectory

#We can make the password functions and generation a module
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
 
foreach ($User in Get-ADUser -Filter *){	
	$password = Get-RandomCharacters -length 5 -characters 'abcdefghiklmnoprstuvwxyz'
	$password += Get-RandomCharacters -length 2 -characters 'ABCDEFGHKLMNOPRSTUVWXYZ'
	$password += Get-RandomCharacters -length 1 -characters '1234567890'
	$password += Get-RandomCharacters -length 2 -characters '!"ยง$%&/()=?}][{@#*+'
	$password = Scramble-String($password)
	$User_SAM = $User.SamAccountName
	if(!($User_SAM -match "Administrator")){
		Set-ADAccountPassword -Identity $User_SAM -Reset -NewPassword (ConvertTo-SecureString -asPlainText $password -Force)
		Add-Content C:\Users\Administrator\Desktop\Reset.txt "$User_SAM $password"
	}
}