##############################################################
# Zerto-mysql-checkpoint.ps1
# 
# By Justin Paul, Zerto Technical Alliances Architect
# Contact info: jp@zerto.com, @recklessop on twitter
# Repo: https://www.github.com/Zerto-ta-public/MySQLDB-Journal-Checkpoints
#
# Full Howto on my blog - https://www.jpaul.me/?p=12645
#
##############################################################

#User customizable variables

#Zerto Info
$VPGName = "MySQL to Azure"
$ZVMServer = "172.16.1.20"
$ZVMPort = 9080
$ZVMUser = "administrator"
$ZVMPass = "password"

#MySQL information
$MySQLServer = "172.16.1.77"
$MySQLUser = "justin"
$privateKey = "C:\id_rsa"

################ No editing needed below this line ##############
Add-PSSnapin Zerto.PS.Commands

$frozen = $false
$tries = 0

$nopasswd = new-object System.Security.SecureString
$Credential = New-Object System.Management.Automation.PSCredential ($MySQLUser, $nopasswd)

$session = New-SSHSession -ComputerName $MySQLServer -ea Stop -AcceptKey:$true -Credential $Credential -KeyFile $privatekey
If (!$session.Connected)
{
    Write-Host "Could Not establish SSH Connection to $MySQLServer"
    exit
}

write-host "SSH Connected"
$SSHId = $session.SessionId

# Freeze MySQLDB
Write-Host "Freezing MySQLDB..."

$RespFreeze = Invoke-SSHCommand -Command "sudo -H /scripts/pre-freeze-script.sh" -SessionId $SSHId -Timeout 1

Write-Host "MySQLDB Frozen."
$frozen = $true


#Do Zerto Check Point
$checkpointInfo = ""
Write-Host "Calling ZVM..."
$checkpointInfo = Set-Checkpoint $ZVMServer $ZVMPort -Username $ZVMUser -Password $ZVMPass -VirtualProtectionGroup $VPGName -Tag 'MySQLDB Frozen by Zerto' -Confirm:$false
If ($checkpointInfo)
{
    Write-Host "Checkpoint Inserted."
} else {
    Write-Host "Unable to Insert Zerto User Checkpoint"
}

#Unfreeze MySQLDB
Write-Host "Unfreezing MySQLDB..."

$UnFreeze = Invoke-SSHCommand -Command "sudo -H /scripts/post-thaw-script.sh" -SessionId $SSHId -Timeout 10

#remove our ssh session
$disconnect = Remove-SSHSession $session

if($disconnect) {
    Write-Host "SSH Disconnected"
}