Install-Module FabricPS -Force
Import-Module FabricPS -Force
Get-InstalledModule -Name "FabricPS"

Connect-AzAccount

Clear-Host

./deploy.ps1