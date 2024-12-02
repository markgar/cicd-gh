# Get all directories in the current directory that end with .Notebook
$notebookDirs = Get-ChildItem -Directory | Where-Object { $_.Name -like '*.Notebook' }

# hard coded workspace id for now
$destinationWorkspaceId = '5ccc33a8-cd6a-4168-98c4-9e8cd70bbace'

# Get all the notebooks in the destination workspace
$notebooks = Get-Notebooks -WorkspaceId $destinationWorkspaceId

# Now that all the notebooks are removed, we can add them back in
# Loop through each directory in the source which is a notebook
foreach ($dir in $notebookDirs) {

    # grab the item name, which is before the '.' in the directory name
    $ItemName = $dir.Name.Split('.')[0]
    
    $existingNotebook = $notebooks.value | Where-Object { $_.DisplayName -eq $ItemName }

    # Check if the notebook already exists in the destination workspace
    if ($null -eq $existingNotebook) {
        # Create a new notebook in the destination workspace
        $newNotebook = New-Notebook `
            -WorkspaceId $destinationWorkspaceId `
            -DisplayName $ItemName
        
        # Set the notebookToUpdateId to the new notebook's Id so I can set the payload
        $notebookToUpdateId = $newNotebook.Id
    } else {
        # Set the notebookToUpdateId to the existing notebook's Id so I can set the payload
        $notebookToUpdateId = $existingNotebook.Id
    }

    # Read the contents of the .platform file and convert it to base64
    $platformFileBytes = Get-Content "./$($dir.Name)/.platform" -Raw
    $platformBase64Content = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($platformFileBytes))
    
    # Read the contents of the notebook-content.py file and convert it to base64
    $pyFileBytes = Get-Content "./$($dir.Name)/notebook-content.py" -Raw
    $pyBase64Content = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($pyFileBytes))

    # Create a payload to send to the API
    $payload = @"
    {
        "definition": {
            "parts": [
                {
                    "path": "notebook-content.py",
                    "payload": "$pyBase64Content",
                    "payloadType": "InlineBase64"
                },
                {
                    "path": ".platform",
                    "payload": "$platformBase64Content",
                    "payloadType": "InlineBase64"
                }
            ]
        }
    }
"@

    # Update the notebook with the payload from git repo    
    Update-NotebookDefinition `
        -WorkspaceId $destinationWorkspaceId `
        -NotebookId $notebookToUpdateId `
        -Definition $payload

    # todo - compare the list of notbooks in the destination that are in the source code
    # if the notebook is not in the source code, delete it from the destination
}