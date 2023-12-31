param(
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$Region = 'southeastasia',

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$ResourceGroup = 'SECTION-DEV-RG',

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$MyRegistry = 'sectiondev',

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$SkuAcr = 'Basic'  
)

# Setup CLI & Parameters for AKS creation
Write-Host "--- Setting up CLI & Params ---" -ForegroundColor Blue

# Create resource group
Write-Host "--- Creating resource group ---" -ForegroundColor Blue
az group create --name $ResourceGroup --location $Region
Write-Host "--- Complete: resource group ---" -ForegroundColor Green

# Create Azure Container Registry
Write-Host "--- Creating ACR ---" -ForegroundColor Blue
az acr create -n $MyRegistry -g $ResourceGroup --sku $SkuAcr --location $Region
Write-Host "--- Complete: ACR ---" -ForegroundColor Green

