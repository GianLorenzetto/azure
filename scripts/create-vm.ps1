. './utils.ps1'

##
## Read VM details
##

$config = Get-ConfigFromJson vm_details.json

##
## Initialise credentials and associated subscription within which
## the VM will be created
##

if (Has-Property $config 'account')
{
    Write-InfoMessage("Creating credentials for username '" + $config.account.username + "'")

    $securePassword = ConvertTo-SecureString $config.account.password -AsPlainText -Force
    $credentials = New-Object System.Management.Automation.PSCredential ($config.account.username, $securePassword)
    Add-AzureAccount -Credential $credentials
}
else
{
    Write-InfoMessage("Interactive account prompt required ...")

    # NB: this is an interactive cmdlet and will open a prompt to enter
    # user name and password
    #Add-AzureAccount
}

# TODO From here this should be a loop over each 'vm' in the config

if (Has-Property $config.vm 'subscriptionName' -and `
    Has-Property $config.vm 'storageAccount')
{
    Write-InfoMessage("Setting storage account to: " + $config.vm.storageAccount)
    Set-StorageAccount $config.vm.subscriptionName $config.vm.storageAccount
}
else 
{
    # TODO try and locate the default storage account? will also need the default subscription name
}

if (-Not (Has-Property $config.vm 'serviceName')
{
    # TODO try and locate the default service
}

Write-InfoMessage("Creating VM '" + $config.vm.name + "' ... (this can take serveral minutes)")
$result = Create-NewVm($config)
Write-InfoMessage("... done!")

Write-InfoMessage("Result: ")
$result