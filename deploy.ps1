function Get-NotebookDefinitionPayload {
    param (
        [Parameter(Mandatory=$true)]
        [System.IO.DirectoryInfo]$dir
    )

    # Read the contents of the .platform file and convert it to base64
    $platformFileBytes = Get-Content "$($dir.FullName)/.platform" -Raw
    $platformBase64Content = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($platformFileBytes))
    
    # Read the contents of the notebook-content.py file and convert it to base64
    $pyFileBytes = Get-Content "$($dir.FullName)/notebook-content.py" -Raw
    $pyBase64Content = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($pyFileBytes))

    # Create a payload to send to the API
    $payloadObject = @{
        definition = @{
            parts = @(
                @{
                    path = "notebook-content.py"
                    payload = $pyBase64Content
                    payloadType = "InlineBase64"
                },
                @{
                    path = ".platform"
                    payload = $platformBase64Content
                    payloadType = "InlineBase64"
                }
            )
        }
    }

    # Convert the payload object to JSON
    $payload = $payloadObject | ConvertTo-Json -Depth 10

    return $payload
}

function Deploy-ItemsOfSpecificType {
    param (
        [string]$DestinationWorkspaceId,
        [string]$Type
    )

    # Get all items of the specified type in the destination workspace
    $items = Get-FabricItems -Type $Type -WorkspaceId $DestinationWorkspaceId

    # Get all directories in the current directory that end with .Notebook
    $itemDirs = Get-ChildItem -Directory | Where-Object { $_.Name -like "*.$Type" }

    # Loop through each directory in the source which is a notebook
    foreach ($dir in $itemDirs) {

        # grab the item name, which is before the '.' in the directory name
        $ItemName = $dir.Name.Split('.')[0]
        
        $existingItem = $items.value | Where-Object { $_.DisplayName -eq $ItemName }

        # Check if the notebook already exists in the destination workspace
        if ($null -eq $existingItem) {
            
            $newItem = New-FabricItem `
                -WorkspaceId $DestinationWorkspaceId `
                -DisplayName $ItemName `
                -Type $Type
            
            # Set the notebookToUpdateId to the new notebook's Id so I can set the payload
            $itemToUpdateId = $newItem.Id
        } else {
            # Set the notebookToUpdateId to the existing notebook's Id so I can set the payload
            $itemToUpdateId = $existingItem.Id
        }
        
        if ($Type -eq 'Notebook') {  
            $payload = Get-NotebookDefinitionPayload -dir $dir
        }

        Update-FabricItemDefinition `
            -WorkspaceId $DestinationWorkspaceId `
            -ItemId $itemToUpdateId `
            -Definition $payload

        # todo - compare the list of notebooks in the destination that are in the source code
        # if the notebook is not in the source code, delete it from the destination
    }
}


# hard coded workspace id for now
$destinationWorkspaceId = 'f4a80368-71ee-4e0f-8734-1e3c32e28d2a'

Deploy-ItemsOfSpecificType -DestinationWorkspaceId $destinationWorkspaceId -Type 'Notebook'