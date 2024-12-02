# CICD for ISV
This is an example of how an ISV might do CICD using a feature branch to merge changes into a main branch, then when a pull request completes, the runner checks out the main branch with the new code and deploys the code directly to the prod workspace.

This does not use a workspace as a source for deploying like a Fabric Pipeline does.