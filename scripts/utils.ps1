# Convenience method for writing a simple info message. Text
# is written in a non-default colour.
function Write-InfoMessage($msg)
{
    Write-Host $msg `n -foregroundcolor DarkCyan
}

# Read VM config from the given JSON file
function Get-ConfigFromJson($pathToJson)
{
    (Get-Content vm_details.json) -join "`n" | ConvertFrom-Json
}

# Test whether the given object has a defined property with the 
# given name
function Has-Property($object, [string] $propertyName)
{
    $object.PSObject.Properties.Match($propertyName).Count
}

# Get all Azure VMs with a matching label. The label can contain
# wild cards and is filtered on a 'like' condition.
# NB To call this function, the session must have already authenticated
#    with an Azure account
# TODO CMDLET
function List-VmDetails([string] $labelFilter)
{
    $vms = Get-AzureVMImage
    $filtered = $vms | Where-Object { $_.Label -like $labelFilter }
    $filtered | ForEach-Object { 
        Write-Host $_.Label -foregroundcolor yellow; 
        Write-Host "  Published: "$_.PublishedDate; 
        Write-Host "  ImageName: "$_.ImageName 
    }
}

# Get available role sizes. Role sizes are sorted on the instance
# size and formatted as a table.
# NB To call this function, the session must have already authenticated
#    with an Azure account
# TODO CMDLET
function List-RoleSizes()
{
    Get-AzureRoleSize | Sort-Object InstanceSize | Format-Table
}

# List all availabe subscriptions, including the default subscription.
function List-Subscriptions()
{
    Get-AzureSubscription | ForEach-Object {
        $postfix = if ($_.IsDefault -eq 'True') { '* (Default)' } else { '' } 
        Write-Host $_.SubscriptionName" "$postfix -foregroundcolor yellow
    }
}

# List all available storage accounts, along with some basic details.
function List-StorageAccounts()
{
    $storageAccounts = Get-AzureStorageAccount
    $storageAccounts | ForEach-Object {
        Write-Host $_.Label -foregroundcolor yellow;
        Write-Host "  Desc:     "$_.StorageAccountDescription;
        Write-Host "  Location: "$_.Location;
        Write-Host "  Type:     "$_.AccountType
    }
}

#List available services.
function List-Services()
{
    Get-AzureService | ForEach-Object {
        Write-Host $_.Label -foregroundcolor yellow
        Write-Host "  Location: "$_.Location
    }
}

# Set the storage account against a subscription.
# NB To call this function, the session must have already authenticated
#    with an Azure account 
function Set-StorageAccount([string] $subscriptionName, [string] $storageAccount)
{
    Set-AzureSubscription -SubscriptionName $subscriptionName -CurrentStorageAccount $storageAccount
}

# Create a new virtual machine.
# NB To call this function, the session must have already authenticated
#    with an Azure account 
function Create-NewVm($config)
{
    $secureAdminPassword = Convertto-Securestring -String $config.vm.adminPassword -AsPlainText -Force

    New-AzureVMConfig -Name $config.vm.name -InstanceSize $config.vm.size -ImageName $config.vm.imageName `
    | Add-AzureProvisioningConfig -Windows -Password $secureAdminPassword -AdminUsername $config.vm.adminUsername  `
    | New-AzureVM -ServiceName $config.vm.serviceName -WaitForBoot
}