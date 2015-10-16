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