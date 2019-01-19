#Active Directory Defense
Set-ExecutionPolicy RemoteSigned
Import-Module ServerManager

foreach ($i in Get-WindowsFeature){
	if($i.Installed -eq $True){
		$CurrentInstalled = $i | select -expand DisplayName
		Write-Host "$CurrentInstalled installed. Would you like to Uninstall? (Y/N)"
		$Response = Read-Host
		$not_done = $True
		while($not_done){
			if($Response -eq "Y" -or $Response -eq "y"){
				Write-Host "Deleting.."
				# TODO
				$not_done = $False
			}
			ElseIf($Response -ne "N" -or $Response -ne "n"){
				Write-Host "Please select a valid option (Y/N)"
				$Response = Read-Host
			}
			else{
				$not_done = $False
			}
		}
	}
}


