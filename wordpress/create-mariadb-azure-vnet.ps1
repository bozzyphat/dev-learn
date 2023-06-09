#Requires -RunAsAdministrator

function Green
{
    process { Write-Host $_ -ForegroundColor Green }
}

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Variable block
$location ="australiaeast"
$resourceGroup ="rg-wp-dev-auseast-001"
$akvName ="akv-wp-dev-aus"
$akvsku ="standard"
$tag ="wordpress-service"
$server ="db-mariadb-dev-auseast-001"
$mariadbsku ="GP_Gen5_2"
$backupretention ="7"
$storagesize ="10240"
$vNet ="vNet-wp-dev-auseast-001"
$vNetAddressPrefix ="10.0.0.0/16"
$subnet ="subnet-wp-dev-auseast-001"
$subnetAddressPrefix ="10.0.1.0/24"
$rule ="rule-wp-dev-auseast"


#Install Azure CLI
Write-Output "Install Azure CLI" | Green
winget install azure-cli

#Install Azure Powershell
Write-Output "Install Azure Powershell" | Green
Install-Module -Name Az -Repository PSGallery 


Write-Output "Using resource group $resourceGroup with login: $login, password: $password..." | Green
az login 

# Create a resource group
Write-Output "Creating $resourceGroup in $location..." | Green
az group create --name $resourceGroup --location "$location" --tags $tag

# Create Azure KeyVault
Write-Output "Creating KeyValut name $akvName in Resources group $resourceGroup..." | Green
az keyvault create --location $location --name $akvName --resource-group $resourceGroup --sku $akvsku

# Set secret for MariaDB Database Login Password
Write-Output "Creating MariaDB Database Login Password in Keyvault $akvName..." | Green

# Variable block for Keyvault Secret
$secretName = "mariadbpass"
$secret = Read-Host 'Type in the password You want to use for MariaDB Database Login' -AsSecureString
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secret)
$plainSecret = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
# Set the value for Secret (password)
az keyvault secret set --name $secretName --vault-name $akvName --value $plainSecret


# Variable block for mariaDB
$login ="azureuser"
$dbpassword = az keyvault secret show --name $SecretName --vault-name $akvName --query value -o tsv
#Write-Output "The password to login  for MariaDB Database is $dbpassword" | Green


# Create a MariaDB server in the resource group
# Name of a server maps to DNS name and is thus required to be globally unique in Azure.
Write-Output "Creating $server in $location..." | Green
az mariadb server create --name $server --resource-group $resourceGroup --location "$location" --admin-user $login --admin-password $dbpassword --sku-name $mariadbsku --ssl-enforcement Disabled --backup-retention $backupretention --geo-redundant-backup Disabled --storage-size $storagesize


# Get available service endpoints for Azure region output is JSON
Write-Output "List of available service endpoints for $location" | Green
az network vnet list-endpoint-services --location "$location"

# Add Azure SQL service endpoint to a subnet while creating the virtual network
Write-Output "Adding service endpoint to $subnet in $vNet" | Green
az network vnet create --resource-group $resourceGroup --name $vNet --address-prefixes $vNetAddressPrefix --location "$location"

# Creates the service endpoint
Write-Output "Creating a service endpoint to $subnet in $vNet" | Green
az network vnet subnet create --resource-group $resourceGroup --name $subnet --vnet-name $vNet --address-prefix $subnetAddressPrefix --service-endpoints Microsoft.SQL

# View service endpoints configured on a subnet
Write-Output "Viewing the service endpoint to $subnet in $vNet" | Green
az network vnet subnet show --resource-group $resourceGroup --name $subnet --vnet-name $vNet

# Create a VNet rule on the server to secure it to the subnet
# Note: resource group (-g) parameter is where the database exists.
# VNet resource group if different should be specified using subnet id (URI) instead of subnet, VNet pair.
Write-Output "Creating a VNet rule on $server to secure it to $subnet in $vNet" | Green
az mariadb server vnet-rule create --name $rule --resource-group $resourceGroup --server $server --vnet-name $vNet --subnet $subnet
# </FullScript>

# Create wordpress databse on the databse server
Write-Output "Create wordpress databse on the databse server $server" | Green
az mariadb server create --resource-group $resourceGroup --server-name $server --name wordpress

#Configure database variables in WordPress
Write-Output "Configure WordPress-specific environment variables in database" | Green

# echo "Deleting all resources"
# az group delete --name $resourceGroup -y