az login

az account set --subscription "Shelfmonitor"

terraform login

terraform init

terraform plan

terraform apply

terraform show

az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/29b29369-f90d-4f6a-87dc-7dbddd20acc9"

Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; rm .\AzureCLI.msi