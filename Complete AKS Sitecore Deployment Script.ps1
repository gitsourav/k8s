#login to Azure
az login

#get your subscription
az account list

#set active subscription if you have more then one
#az account set --name "<name of your subscription.>"
az account set --subscription "########"

#check you are set in right subscription
az group list

#Project location
$projectlocation= "C:\sitecore10\sitecore-kubernetes-sample-main\k8s"

#common variables
$priLocation= "southeastasia"
$priClusterResourceGroupName-"SECTION-PROD-RG"
$priNodeResourceGroupName= "$($ResourceGroup)_AKS_BackEnd"
#SpriAddResourceGroupHame="prod-pri-resources-rg"
$acr = "sectiondev"

#azure sql server variables
$priSqlServerName="prod-pri-sql"
$sqladminuser="sqladmin"
$sqladminpassword="P@ssword1234"

#azure elastic pool variables
$priElasticPoolName="prod-pri-pool"
$edition= "Standard"
$capacity=100

#azure aks cluster variables.
$priClusterName="SECTION-PROD-AKS"
$nodecount=1
$nodevmsize= "Standard_B2ms"
$vmsettype= "VirtualMachineScaleSets"
$networkplugin= "azure"
$monitoringenableaddons="monitoring"
$kubernetesversion="1.19.6"
$ingressenableaddons="ingress-appgw"
$priAppGwName="prod-pri-appgw"
$priAppGwSubnetcidr="172.20.1.0/24"
$priWindowsAdminUser = "aksadmin"
$priWindowsAdminPassword= "Admin@aks12345"

#Azure aks windows node pool variables.
$winnodepoolname="win"
$ostype="windows"
$winnodevmsize= "Standard_DS2_v2"
$winnodecount=1

#Virtual network Variables.
$priVnetName = "prod-pri-vnet"
$priVnetSubnet = "prod-pri-subnet"
$priAppgwSubnetcidr = "172.20.3.0/24"
$pridockerBridgeAddress = "172.17.0.1/16"
$priDnsServiceip = "10.2.0.10"
$priServicecidr = "10.2.0.0/16"
                               I
#Create Primary resource group
#one time activity
az group create `
 --location $prilocation `
 --name $priClusterResourceGroupName- `
 --tags project=dngp2

#Create Backend resource group
#one time activity
az group create `
--location $prilocation `
--name $priNodeResourceGroupName `
--tags project=dngp2
 
#setting up Primary Vnet for cluster
#one time activity
az network vnet create `
 --resource-group $priNodeResourceGroupName `
 --mame $priVnetName `
 --address-prefix 172.20.0.0/16 
 
#setup subnets for pri aks
 az network vnet subnet create `
 --resource-group $priNodeResourceGroupName `
 --vnet-name $priVnetName `
 --name SpriVnetSubnet `
 --address-prefixes 172.20.0.0/23

#we will be creating nodes in this subnet
$akssubnet_id = az network vnet subnet list `
 --resource-group $priNodeResourceGroupName `
 --vnet-name $priVnetName `
 --query "[?name == '$priVnetSubnet'].[id]" `
 --output tsv

#setup the cluster first.
#you might just have to change the project tag here.
az aks create `
 --resource-group $priClusterResourceGroupName `
 --node-resource-group $priNodeResourceGroupName `
 --name $priClusterName `
 --node-count $nodecount `
 --node-vm-size $nodevmsize `
 --windows-admin-username $priWindowsAdminUser `
 --windows-admin-password $priWindowsAdminPassword `
 --vm-set-type $vmsettype `
 --network-plugin $networkplugin `
 --location $priLocation `
 --enable-addons $monitoringenableaddons `
 --kubernetes-version $kubernetesversion `
 --tags Project=dngp2 `
 --enable-addons $ingressenableaddons `
 --appgw-name $priAppGwName `
 --apppw-subnet-cidr $priAppGwSubnetcidr `
 --attach-acr $acr `
 --docker-bridge-address $pridockerBridgeAddress `
 --dns-service-ip $priDnsServiceip `
 --service-cidr $priServicecidr `
 --vnet-subnet-id $akssubnet_id `
 --verbose

#Setting up Azure Sql server database as the pre-requisites.
#make sure the sql user and password is similar to what you give in kubernets secrets.
az sql server create `
 --name $priSqlServerName `
 --resource-group $priClusterResourceGroupName `
 --location $priLocation `
 --admin-user $sqladminuser `
 --admin-password $sqladminpassword

#REM allowing access to SQL remotely
az sql server firewall-rule create `
 --resource-group $priClusterResourceGroupName `
 --server SpriSq1ServerName `
 --name AllowAzure `
 --start-ip-address 0.0.0.0 `
 --end-ip-address 0.0.0.0 `
 --verbose
 
#Setting up Azure Sql Server Elastic Pool.
az sql elastic-pool create `
 --name $priElasticPoolName `
 --resource-group $priClusterResourceGroupName `
 --server SpriSq1ServerName `
 --edition $edition `
 --capacity $capacity

 # Add windows server nodepool
Write-Host "--- Creating Windows Server Node Pool ---" -ForegroundColor Blue
az aks nodepool add `
  --cluster-name $priClusterName `
  --name $winnodepoolname `
  --resource-group $priNodeResourceGroupName `
  --os-type $ostype `
  --node-vm-size $winnodevmsize `
  --kubernetes-version $kubernetesversion `
  --node-count $winnodecount `
  --enable-cluster-autoscaler `
  --min-count 1 `
  --max-count 2 `
  --verbose

az aks get-credentials -a `
  --resource-group $priClusterResourceGroupName `
  --name $priClusterName `
  --overwrite-existing `
  --verbose

kubect apply -k .\secrets
#kubect delete -k .\secrets


kubectl apply -f .\volumes\azurestorage\mssql.yaml
kubectl apply -f .\volumes\azurestorage\redis.yaml
kubectl apply -f .\volumes\azurestorage\solr.yaml
kubectl apply -k .\external\
#kubect delete -k .\external


kubect apply -k .\init
#kubect delete -k .\init



kubect apply -k .\ingress-nginx
#kubect delete -k .\ingress


kubectl apply -f .\volumes\azurefile
kubectl apply -k .\