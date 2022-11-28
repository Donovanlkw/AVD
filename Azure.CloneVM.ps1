
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


####Powershell run inside the windwos 10.

