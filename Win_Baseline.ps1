#Requires -RunAsAdministrator

#Get Defender Parameters
$defenderVals = Get-MpComputerStatus

#Job for background scan
$scan_job = ""

#Windows Defender
if($defenderVals){
    #Enable Windows Defender
    Write-Host "Fully enabling Windows Defender Antivirus..."
    Set-MpPreference -DisableRealtimeMonitoring $false
    Set-MpPreference -DisableScriptScanning $false
    Set-MpPreference -DisableArchiveScanning $false
    Set-MpPreference -DisableAutoExclusions $false
    Set-MpPreference -DisableBehaviorMonitoring $false
    Set-MpPreference -DisableIOAVProtection $false
    Set-MpPreference -DisableScanningNetworkFiles $false
    Set-MpPreference -DisableRemovableDriveScanning $false

    #Update Defender
    Update-MpSignature -UpdateSource MicrosoftUpdateServer

    #Run Defender Quick Scan
    Write-Host "Running Quick Scan on Background" -ForegroundColor Cyan
    $scan_job = Start-Job{ Start-MpScan -ScanType QuickScan}
}
else{
    Write-Host "Windows Defender not found" -ForegroundColor Green
}

#Windows Firewall

#Enable Firewall
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True -DefaultInboundAction Block 


#Windows Update
if(!Get-Command -Module PSWindowsUpdate){
    Install-Module PSWindowsUpdate
}
Import-Module PSWindowsUpdate
Add-WUServiceManager -ServiceID 7971f918-a847-4430-9279-4a52d1efe18d
$update_job = Start-Job{Get-WUInstall -MicrosoftUpdate -AcceptAll -IgnoreReboot -Install}

#User Management
#Getting HS Readme Specific Variables
$shortcut_ob = New-Object -ComObject WScript.Shell
$tpath = $sh.CreateShortcut("$HOME\Desktop\CCS README.lnk")
$urlp = $sh.CreateShortcut($tpath).TargetPath

#Parse User Data from Website
$data = $web.AllElements | Where{$_.TagName -eq "Pre"} | Select-Object -expand InnerText
$lines = ($data -split "`r`n")
[System.Collections.ArrayList]$UserList = @()
[System.Collections.ArrayList]$AdminList = @()
$admin=$true
foreach ($l in $lines) {
    if($l -NotLike "*Administrator*" -and $l -NotLike "*Users*" -and $l -NotLike "*password*"){
        if($l -eq ""){
            $admin=$false
            continue
        }
        if($admin){
            $AdminList.Add(($l.split(" "))[0])
        }
        $UserList.Add(($l.split(" "))[0])
    }
}

[System.Collections.ArrayList]$CurrentUsers = (Get-LocalUser).Name

#Get rid of default users from list
for($i=0;$i-lt$CurrentUsers.Count;$i++) {
    $c = $CurrentUsers[$i]
    if($c -match "Guest" -or $c -match "Administrator" -or $c -like "*default*") {
        $CurrentUsers.Remove($c)
        $i--
    }
}

#Compare lists and get malicious users
$malicious_users = $CurrentUsers | ?{$UserList -notcontains $_}

#Get rid of malicious users
foreach ($malicious in $malicious_users) {
    Remove-LocalUser -Name $malicious
}

#Change Passwords
$Password = "*************"
foreach($user in $UserList){
    $UserAccount = Get-LocalUser -Name $user
    $UserAccount | Set-LocalUser -Password (ConvertTo-SecureString $Password -AsPlainText -force)
}

#Adjust Admin Privileges
$currentadmins = ((Get-LocalGroupMember Administrators).name -split("\\"))| select -unique
$currentadmins = $currentadmins[2..($currentadmins.length)]

$malicious_admins = $currentadmins | ?{$AdminList -notcontains $_}
foreach($mal in $malicious_admins){
    Remove-LocalGroupMember -Group "Administrators" -Member $mal
}

Wait-Job $scan_job
Wait-Job $update_job
