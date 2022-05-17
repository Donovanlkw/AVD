$Location = 'EastAsia'
$ResourceGroupName = 'MyResourceGroup'
$vnet = 'MyVNet'
$VMname= 'AVD11'

$vnet = @{
    Name = $vnet
    ResourceGroupName = $ResourceGroupName
    Location = $Location
    AddressPrefix = '10.0.0.0/16'    
}
$virtualNetwork = New-AzVirtualNetwork @vnet

$subnet = @{
    Name = 'default'
    VirtualNetwork = $virtualNetwork
    AddressPrefix = '10.0.0.0/24'
}
$subnetConfig = Add-AzVirtualNetworkSubnetConfig @subnet



$Location = 'EastAsia'
$ResourceGroupName = 'MyResourceGroup'
$vnet = 'MyVNet'
$vmName = 'vm-lab-win001'

################ Create a VM Configuration ################ 
$vmConfig = New-AzVMConfig -VMName $vmName -VMSize $VMSize -AvailabilitySetID $Aset.Id | `
Set-AzVMOperatingSystem -Windows -ComputerName $vmName -Credential $Cred | `
Set-AzVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2019-Datacenter -Version latest | `
Add-AzVMNetworkInterface -Id $nic.Id




New-AzResourceGroup -Name $ResourceGroupName -Location $Location

New-AzStorageAccount -ResourceGroupName MyResourceGroup -AccountName sa8765456789876 -Location westus -SkuName Standard_GRS

New-AzStorageAccount -ResourceGroupName MyResourceGroup -AccountName sa000gytghjnhg -Location westus -SkuName Standard_GRS -Kind BlobStorage -AccessTier Hot

New-AzStorageAccount -ResourceGroupName MyResourceGroup -AccountName sa0005y6u7yjhgn -Location westus -SkuName Standard_GRS -Kind StorageV2 -AssignIdentity
