################ Definition of Primary site ##################

$Location = 'EastAsia'
$ResourceGroupName      = 'MyResourceGroup'
$ResourceGroupNameNET   = 'MyResourceGroupNET'
$AvailabilitySet	    = "AvailabilitySet"
$vnet = 'MyVNet'
$VMname= 'AVD11'

################ Create a ResrouceGroup ##################
New-AzResourceGroup -Name $ResourceGroupName -Location $Location
New-AzResourceGroup -Name $ResourceGroupNameNET -Location $Location

################ Provisioning Availability Set
$newAvailabilitySetbkPri = New-AzAvailabilitySet -Name $AvailabilitySet -ResourceGroupName $ResourceGroupName -Location $Location -Sku Aligned -PlatformFaultDomaincount 2 -PlatformUpdateDomainCount 5

if ($newAvailabilitySetbkPri)
{
	Write-Output "Provisioning Availability Set Completed."
} else{
	Write-Error -Message $_.Exception
}


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

New-AzStorageAccount -ResourceGroupName $ResourceGroupName -AccountName sav1000abc -Location $Location -SkuName Standard_GRS -Kind Storage
New-AzStorageAccount -ResourceGroupName $ResourceGroupName -AccountName sav2000abc -Location $Location -SkuName Standard_GRS -Kind StorageV2
New-AzStorageAccount -ResourceGroupName $ResourceGroupName -AccountName sav2000abc1 -Location $Location -SkuName Standard_GRS -Kind StorageV2  -EnableHierarchicalNamespace $true -EnableAzureActiveDirectoryDomainServicesForFile $true -EnableLargeFileShare
New-AzStorageAccount -ResourceGroupName $ResourceGroupName -AccountName sabs000abc -Location $Location -SkuName Standard_GRS -Kind BlobStorage -AccessTier Hot
New-AzStorageAccount -ResourceGroupName $ResourceGroupName -AccountName sabb000abc -Location $Location -SkuName Premium_LRS -Kind BlockBlobStorage -AccessTier Hot
New-AzStorageAccount -ResourceGroupName $ResourceGroupName -AccountName safs000abc -Location $Location -SkuName Premium_LRS -Kind FileStorage -AccessTier Hot



$vmName = 'vm-lab-win001'

################ Create a VM Configuration ################ 
$vmConfig = New-AzVMConfig -VMName $vmName -VMSize $VMSize -AvailabilitySetID $Aset.Id | `
Set-AzVMOperatingSystem -Windows -ComputerName $vmName -Credential $Cred | `
Set-AzVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2019-Datacenter -Version latest | `
Add-AzVMNetworkInterface -Id $nic.Id
