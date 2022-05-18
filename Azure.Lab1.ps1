################ Definition of Primary site ##################

$Location = 'EastAsia'
$ResourceGroupName = 'MyResourceGroup'
$ResourceGroupNameNET = 'MyResourceGroupNET'
$vnet = 'MyVNet'
$VMname= 'AVD11'

################ Create a ResrouceGroup ##################
New-AzResourceGroup -Name $ResourceGroupName -Location $Location
New-AzResourceGroup -Name $ResourceGroupNameNET -Location $Location


################ Create a Virtual Network ##################
$vnet = @{
    Name = $vnet
    ResourceGroupName = $ResourceGroupNameNET
    Location = $Location
    AddressPrefix = '10.0.0.0/8'    
}
$virtualNetwork = New-AzVirtualNetwork @vnet

$subnet = @{
    Name = 'default'
    VirtualNetwork = $virtualNetwork
    AddressPrefix = '10.0.0.0/24'
}
$subnetConfig = Add-AzVirtualNetworkSubnetConfig @subnet
$virtualNetwork | Set-AzVirtualNetwork

################ Create a Storage Account ################ 
New-AzStorageAccount -ResourceGroupName $ResourceGroupName -AccountName sabs999999999a -Location $Location -SkuName Standard_GRS -Kind BlobStorage
New-AzStorageAccount -ResourceGroupName $ResourceGroupName -AccountName sabb9999999999a -Location $Location -SkuName Standard_GRS -Kind BlockBlobStorage
New-AzStorageAccount -ResourceGroupName $ResourceGroupName -AccountName safs9999999999a -Location $Location -SkuName Standard_GRS -Kind FileStorage
New-AzStorageAccount -ResourceGroupName $ResourceGroupName -AccountName sav19999999999a -Location $Location -SkuName Standard_GRS -Kind Storage
New-AzStorageAccount -ResourceGroupName $ResourceGroupName -AccountName sav29999999999a -Location $Location -SkuName Standard_GRS -Kind StorageV2





$vmName = 'vm-lab-win001'

################ Create a VM Configuration ################ 
$vmConfig = New-AzVMConfig -VMName $vmName -VMSize $VMSize -AvailabilitySetID $Aset.Id | `
Set-AzVMOperatingSystem -Windows -ComputerName $vmName -Credential $Cred | `
Set-AzVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2019-Datacenter -Version latest | `
Add-AzVMNetworkInterface -Id $nic.Id
