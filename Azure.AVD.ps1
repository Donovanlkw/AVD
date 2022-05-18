Install-Module -Name Az.DesktopVirtualization

Get-AzLocation


Get-AzWvdSessionHost -HostPoolName <hostpoolname> -Name <sessionhostname> -ResourceGroupName <resourcegroupname>

Get-AzWvdSessionHost -HostPoolName <hostpoolname> -Name <sessionhostname> -ResourceGroupName <resourcegroupname> -SubscriptionId <subscriptionGUID>

$HOSTPool = 'HOSTPool'
$workspacename ='workspacename'
$DesktopGroup= 'DesktopGroup'

####Create a host pool
New-AzWvdHostPool -ResourceGroupName $ResourceGroupName  -Location $Location -Name $HOSTPool -WorkspaceName $workspacename -HostPoolType Pooled -LoadBalancerType  BreadthFirst -DesktopAppGroupName $DesktopGroup 


https://docs.microsoft.com/en-us/azure/virtual-desktop/create-host-pools-powershell?tabs=azure-powershell
