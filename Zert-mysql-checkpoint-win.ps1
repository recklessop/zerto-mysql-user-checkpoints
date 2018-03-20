##############################################################
# Zerto-mysql-checkpoint-win.ps1
# 
# By Justin Paul, Zerto Technical Alliances Architect
# Contact info: jp@zerto.com, @recklessop on twitter
# Repo: https://www.github.com/Zerto-ta-public/MySQLDB-Journal-Checkpoints
#
# This script is used to flush open table data to disk before taking a
# Zerto User Checkpoint. Once the checkpoint is created. Tables are unlocked
#
# Requirements:
# Connector/Net from Mysql is required.
# https://dev.mysql.com/downloads/connector/net/
# 
# Also the Zerto Powershell Cmdlets
# http://www.zerto.com/myzerto (under the download section)
#
# Lastly you need adbertram's MySQL Powershell Module
# https://github.com/adbertram/MySQL/
#
# How to for installing these can be found here:
# https://mcpmag.com/articles/2016/03/02/querying-mysql-databases.aspx
#
##############################################################

#User customizable variables

#Zerto Info
$VPGName = "Name of MySQL VPG"
$ZVMServer = "172.16.1.20"
$ZVMPort = 9080
$ZVMUser = "administrator"
$ZVMPass = "password"

#MySQL information
$MySQLServer = "172.16.1.96"
$MySQLDatabase = 'data'
$MySQLUser = "worker"
$MySQLPass = "Zertodata"


################ No editing needed below this line ##############
$MySQLPass = ConvertTo-SecureString $MySQLPass -AsPlainText -Force
$dbcred = New-Object System.Management.Automation.PSCredential ($MySQLUser, $MySQLPass)

Add-PSSnapin Zerto.PS.Commands

# Connect and Freeze MySQL
Connect-MySqlServer -Credential $dbcred -ComputerName $MySQLServer -Database $MySQLDatabase
Invoke-MySqlQuery -Query 'FLUSH TABLES WITH READ LOCK'


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

#unfreeze mysql after checkpoint
Write-Host "Unlocking Tables"
Invoke-MySqlQuery -Query 'UNLOCK TABLES'


Disconnect-MySqlServer