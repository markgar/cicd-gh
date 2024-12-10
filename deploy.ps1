Install-Module FabricPS -Force
Import-Module FabricPS -Force
Get-InstalledModule FabricPS 

. ./Deploy-FabricItems.ps1

# hard coded workspace id for now
$destinationWorkspaceId = 'f4a80368-71ee-4e0f-8734-1e3c32e28d2a'

Deploy-FabricItems -DestinationWorkspaceId $destinationWorkspaceId -Type 'Notebook'