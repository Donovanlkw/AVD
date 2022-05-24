################ Definition of Primary site ##################

$Location = 'westus'
$ResourceGroupName      = 'MyResourceGroup'
$ResourceGroupNameNET   = 'MyResourceGroupNET'
$AvailabilitySet	    = "AvailabilitySet"
$vnet = 'MyVNet'
$subnet ='MySubnet'
$NSGName = 'MyNSG'
$NetworkWatcher		="MyNetworkWatcher"

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
    Name = $subnet 
    VirtualNetwork = $virtualNetwork
    AddressPrefix = '10.0.0.0/24'
}
$subnetConfig = Add-AzVirtualNetworkSubnetConfig @subnet
$virtualNetwork | Set-AzVirtualNetwork






################ Create a new NIC. ################ 
$Subnetpath=$virtualNetwork.id+'/'+$subnet.name







$Subnet = Get-AzVirtualNetwork -Name "VirtualNetwork1" -ResourceGroupName "ResourceGroup1" 
$IPconfig = New-AzNetworkInterfaceIpConfig -Name "IPConfig1" -PrivateIpAddressVersion IPv4 -PrivateIpAddress "10.0.1.10" -SubnetId $Subnet.Subnets[0].Id
New-AzNetworkInterface -Name "NetworkInterface1" -ResourceGroupName "ResourceGroup1" -Location "centralus" -IpConfiguration $IPconfig

New-AzNetworkInterface -Location $location -Name 'NetworkInterface1' -ResourceGroupName $ResourceGroupNameNET -SubnetId 
'/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/ResourceGroup1/providers/Microsoft.Network/virtualNetworks/VirtualNetwork1/subnets/Subnet1'








################ Create a Network Watcher ##################
New-AzNetworkWatcher -Name $NetworkWatcher -ResourceGroupName $ResourceGroupNameNET -Location $Location 




################ Create a NSG ################ 
$rdpRule = New-AzNetworkSecurityRuleConfig -Name rdp-rule -Description "Allow RDP" -Access Allow -Protocol Tcp -Direction Inbound -Priority 100 -SourceAddressPrefix Internet -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389
New-AzNetworkSecurityGroup -Name $NSGName -ResourceGroupName $ResourceGroupNameNET  -Location $Location  -SecurityRules $rdpRule


################ Create a Storage Account ################ 
New-AzStorageAccount -ResourceGroupName $ResourceGroupName -AccountName sav2000abc -Location $Location -SkuName Standard_GRS -Kind StorageV2

New-AzStorageAccount -ResourceGroupName $ResourceGroupName -AccountName sav1000abc -Location $Location -SkuName Standard_GRS -Kind Storage
New-AzStorageAccount -ResourceGroupName $ResourceGroupName -AccountName sav2000abc1 -Location $Location -SkuName Standard_GRS -Kind StorageV2  -EnableHierarchicalNamespace $true -EnableAzureActiveDirectoryDomainServicesForFile $true -EnableLargeFileShare
New-AzStorageAccount -ResourceGroupName $ResourceGroupName -AccountName sabs000abc -Location $Location -SkuName Standard_GRS -Kind BlobStorage -AccessTier Hot
New-AzStorageAccount -ResourceGroupName $ResourceGroupName -AccountName sabb000abc -Location $Location -SkuName Premium_LRS -Kind BlockBlobStorage -AccessTier Hot
New-AzStorageAccount -ResourceGroupName $ResourceGroupName -AccountName safs000abc -Location $Location -SkuName Premium_LRS -Kind FileStorage -AccessTier Hot


################ Create a new VM ################ 
$vmName = 'vm-lab-win001'

################ Create a VM Configuration ################ 
$vmConfig = New-AzVMConfig -VMName $vmName -VMSize $VMSize -AvailabilitySetID $Aset.Id | `
Set-AzVMOperatingSystem -Windows -ComputerName $vmName -Credential $Cred | `
Set-AzVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2019-Datacenter -Version latest | `
Add-AzVMNetworkInterface -Id $nic.Id
