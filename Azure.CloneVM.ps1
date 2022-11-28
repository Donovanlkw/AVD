
$MasterServer = 'abc'

$resourceGroupName = '
$location = 'eastasia' 
$VMSize = "Standard_D8_v3"
$disktype="StandardSSD_LRS"

$VNet=""
$SubnetName = ""

Select-AzSubscription xxx
$dateStr = Get-Date -Format "yyyyMMdd"
$SnapshotName= $MasterServer+"-"+$dateStr+".snapshot"

#Create a virtual machine from a managed disk
$NewVMName = $MasterServer+"C1"
$NewDiskName = $MasterServer+"C1-"+$dateStr
$newVMNIcName= $MasterServer+"C1-"+"NIC"
$newNICRGName= $resourceGroupName
$destinationResourceGroup=$resourceGroupName
$newRGName=$resourceGroupName


### --- Taking Snapshot
$vm = Get-AzVM -ResourceGroupName $resourceGroupName -Name $MasterServer
$snapshotconfig =  New-AzSnapshotConfig -SourceUri $vm.StorageProfile.OsDisk.ManagedDisk.Id -Location $location -CreateOption copy
$Snapshot = New-AzSnapshot -Snapshot $snapshotconfig -SnapshotName $snapshotName -ResourceGroupName $resourceGroupName 


# Create the new disk
$osDisk = New-AzDisk -DiskName $NewDiskName -Disk  (New-AzDiskConfig  -Location $location -skuName $disktype -CreateOption Copy -SourceResourceId $snapshot.Id) -ResourceGroupName $destinationResourceGroup

# Create the new NIC
$NewVnet=Get-AzVirtualNetwork -name $VNet
$Newvnet.Subnets[0].name
$nic = New-AzNetworkInterface -Name $newVMNIcName -ResourceGroupName $destinationResourceGroup -Location $location -SubnetId $Newvnet.Subnets[0].Id

# Create the new VM
$vmConfig = New-AzVMConfig -VMName $NewvmName -VMSize $VMSize
$vm = Add-AzVMNetworkInterface -VM $vmConfig -Id $nic.Id
$vm = Set-AzVMOSDisk -VM $vm -ManagedDiskId $osDisk.Id -StorageAccountType Standard_LRS -DiskSizeInGB 128 -CreateOption Attach -Windows
New-AzVM -ResourceGroupName $destinationResourceGroup -Location $location -VM $vm



### Powershell run inside the windwos 10.
### === 1st reboot === ###
$userid = "tmpadmin"
$Password = "Password1"
$Encryptedpassword=$Password | ConvertTo-SecureString -Force -AsPlainText
New-LocalUser $userid -Password $Password -FullName "tmp adm" -Description "tmp adm for Cloning"
Add-LocalGroupMember -Group "Administrators" -Member $userid
Get-AppxPackage | Remove-AppxPackage -AllUsers 
C:\Windows\system32\sysprep\sysprep.exe /generalize /oobe /reboot


### === 2nd reboot === ###
$Domainuserid = "mfcgd\leekwun"
$userid = "tmpadmin"
$Password = "Password1"
$Domain= "MFCGD.COM"
$OUPath= "OU=VDI,OU=Win10,OU=Hong Kong,OU=Managed Computers,DC=MFCGD,DC=COM"
Set-ExecutionPolicy Unrestricted -force
add-computer -NewName $Newname –domainname $domain -OUPath $OUPath -Credential $domainuserid 
Remove-LocalUser -name $userid
Set-ExecutionPolicy restricted
shutdown -r -t 0
###################################################################################################



$file = "c:\$task.ps1"

### Create a auto run RDS Configuration
Get-ScheduledTask
$resumeActionscript = "-WindowStyle Normal -NoLogo -NoProfile -File $file"
$act = New-ScheduledTaskAction -Execute "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -Argument $resumeActionscript
$trig = New-ScheduledTaskTrigger -AtStartup
Register-ScheduledTask -TaskName $task -user $user -password $pwd -Action $act -Trigger $trig -RunLevel Highest


### Create a Powershell script file for configure RDS script
New-Item $file -force
Set-Content $file '$BrokerServer="' -NoNewline
Add-Content $file "$BrokerServer" -NoNewline
Add-Content $file '"'

Add-Content $file '$CollectionName="' -NoNewline
Add-Content $file "$CollectionName" -NoNewline
Add-Content $file '"'

Add-Content $file '
$NewBrokerServer= [System.Net.Dns]::GetHostByName($env:computerName).HostName
$NewSessionServer= [System.Net.Dns]::GetHostByName($env:computerName).HostName
Import-Module ServerManager
Add-RDServer -Server $NewBrokerServer -Role "RDS-CONNECTION-BROKER" -ConnectionBroker $BrokerServer *>&1 >> C:\temp\output1.txt
Add-RDServer -Server $NewSessionServer -Role "RDS-RD-SERVER" -ConnectionBroker $BrokerServer *>&1 >> C:\temp\output2.txt
Add-RDSessionHost -CollectionName $CollectionName -SessionHost $NewSessionServer -ConnectionBroker $BrokerServer *>&1 >> C:\temp\output3.txt
Set-RDSessionHost -SessionHost $NewSessionServer  -NewConnectionAllowed "No" -ConnectionBroker $BrokerServer 
' 

Add-Content $file 'Unregister-ScheduledTask '  -NoNewline 
Add-Content $file "$task " -NoNewline
Add-Content $file '-Confirm:$false' 

Add-Content $file '
### Restore security configuration
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\"  -Name "MinEncryptionLevel" -Value "3"  -PropertyType "DWORD"
set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\" -Name "DisableDomainCreds" -value "1"
set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -value "1"
### Restore security policy configuration
secedit /configure /db C:\Windows\security\local.sdb /areas USER_RIGHTS /cfg  c:\temp\secpolfinal.inf
c:\temp\Ericom\install.ps1
Restart-Computer
'
