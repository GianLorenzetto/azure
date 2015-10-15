function Has-Property($object, \[string\] $propertyName)
{
    $object.PSObject.Properties.Match($propertyName).Count > 0
}

# read VM details

$config = (Get-Content vm_details.json) -join "`n" | ConvertFrom-Json

##
## initialise credentials and associated subscription within which
## the VM will be created
##

"Adding account '" + $config.accountName + "'"

if ((Has-Property $config, 'accountUsername') -and `
    (Has-Property $config, 'accountPassword'))
{
    "creating credentials"

    $securePassword = ConvertTo-SecureString $config.password -AsPlainText -Force
    $credentials = New-Object System.Management.Automation.PSCredential ($config.accountUsername, $securePassword)
    #Add-AzureAccount -Credential $credentials
}
else
{
    # NB: this is an interactive cmdlet and will open a prompt to enter
    # user name and password

"going interactive"

    #Add-AzureAccount
}

"Creating VM '" + $config.vmName + "'"