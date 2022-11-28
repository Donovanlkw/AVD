
$MasterServer = 'AZWVDPHE1787 '

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


### === Powershell run inside the windwos 10.


### === 1st reboot === ###
$userid = "tmpadmin"
$Password = "Password1"
$newvmname = "$env:computername"+"C3"

$Encryptedpassword=$Password | ConvertTo-SecureString -Force -AsPlainText
New-LocalUser $userid -Password $Encryptedpassword -FullName "tmp adm" -Description "tmp adm for Cloning"
Add-LocalGroupMember -Group "Administrators" -Member $userid

###--- Create a schedule job for rename after reboot.

$task="nenew"
$file = "c:\$task.ps1"
Get-ScheduledTask
$resumeActionscript = "-WindowStyle Normal -NoLogo -NoProfile -File $file"
$act = New-ScheduledTaskAction -Execute "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -Argument $resumeActionscript
$trig = New-ScheduledTaskTrigger -AtStartup
Register-ScheduledTask -TaskName $task -user $userid -password $Password -Action $act -Trigger $trig -RunLevel Highest

### Create a Powershell script file for configure RDS script
New-Item $file -force
Set-Content $file '$Domainuserid = "mfcgd\"'
Add-Content $file '$userid = "tmpadmin"' 
Add-Content $file '$Password = "Password1"' 
Add-Content $file '$Domain= "MFCGD.COM"' 
Add-Content $file '$OUPath= "OU=VDI,OU=Win10,OU=Hong Kong,OU=Managed Computers,DC=MFCGD,DC=COM"' 
Add-Content $file 'Set-ExecutionPolicy Unrestricted -force' 
Add-Content $file 'add-computer -NewName $Newname –domainname $domain -OUPath $OUPath -Credential $domainuserid ' 
Add-Content $file 'Remove-LocalUser -name $userid' 
Add-Content $file 'Set-ExecutionPolicy restricted' 

Add-Content $file 'Unregister-ScheduledTask '  -NoNewline 
Add-Content $file "$task " -NoNewline
Add-Content $file '-Confirm:$false' 
Add-Content $file 'del $file -force' 

Add-Content $file 'shutdown -r -t 0' 

Get-AppxPackage | Remove-AppxPackage -AllUsers 
C:\Windows\system32\sysprep\sysprep.exe /generalize /oobe /reboot

###################################################################################################
