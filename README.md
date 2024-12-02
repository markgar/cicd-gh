# CICD for ISV
This is an example of how an ISV might do CICD using a feature branch to merge changes into a main branch, then when a pull request completes, the runner checks out the main branch with the new code and deploys the code directly to the prod workspace.

This does not use a workspace as a source for deploying like a Fabric Pipeline does.

# FabricPS
This code relies on a powershell module called FabricPS, also written by Mark Garner.

FabricPS takes the Fabric Rest API calls and makes them easier to use by making simple Powershell functions and packating them into a Module on Powershell Gallery.  You can install this by executing '''Install-Module FabricPS'''

# Process
New code is introduced by a feature branch and a feature workspace.  Create a new workspace in Fabric and create a feature branch in the Fabric UI.  When coding is complete in the Fabric UI, create a pull request and merge it.  This will move the new code to the main branch.  You can now delete the feature branch and the feature workspace.

At this point, the workflow (github action) can run to deploy the code to all the production workspaces.  Today, this workflow is run manually, but could be triggered by a pull requst merge.  The workflow today checks out main and deploys to the production tenant, but future optimizations could include a testing step where the code has automated tests run and approvals given before the code is finally deployed to all the production tenants.

At this point, the production workspace is hard-coded into the powershell script that the runner runs to execute deployment.  A future update could make this more flexible.

A process that bootstraps new tenants (production workspaces) would create a new workspace and add the Workspace's Id to a list that the deployment script loops through to deploy to all known tenants.