#login to Azure
az login

#get your subscription
az account list

#set your active subscription if you have more thatn one 
#az account set --name "<name of your subscription>"
#az account set --subscription "#################"

#check you are set in right subscription
az group list
