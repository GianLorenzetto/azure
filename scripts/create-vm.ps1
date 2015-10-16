. './utils.ps1'

##
## Read VM details
##

$config = Get-ConfigFromJson vm_details.json

##
## Initialise credentials and associated subscription within which
## the VM will be created
##

if ((Has-Property $config 'accountUsername') -and `
    (Has-Property $config 'accountPassword'))
{
    "** Creating credentials for username '" + $config.accountUsername + "'"

    $securePassword = ConvertTo-SecureString $config.accountPassword -AsPlainText -Force
    $credentials = New-Object System.Management.Automation.PSCredential ($config.accountUsername, $securePassword)
    #Add-AzureAccount -Credential $credentials
}
else
{
    "** Interactive account prompt required ..."

    # NB: this is an interactive cmdlet and will open a prompt to enter
    # user name and password
    #Add-AzureAccount
}

"Creating VM '" + $config.vmName + "'"