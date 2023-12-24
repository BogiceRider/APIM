#!/bin/bash
if [ $# -eq 1 ]; then
  echo "Setting up infrastructure for API Management"
else
  echo "Please provide exactly one argument."
fi

GITPAT=$1
RESOURCE_GROUP=bogice1-rg
apiappname=bogice-apim
aspName=bogice-asp
apikeyvault=bogice-apim-kv
apiSecretName=Git-PAT
gitUrl=https://github.com/BogiceRider/APIM.git


printf "\nCreating Resource group ... (1/5)\n\n"
az group create --name $RESOURCE_GROUP --location centralus

printf "\nCreating App Service plan in Basic tier ... (2/5)\n\n"
az appservice plan create --name $aspName --resource-group $RESOURCE_GROUP --sku B1 --location centralus

printf "\nCreating API App ... (3/5)\n\n"
az webapp create --name $apiappname --resource-group $RESOURCE_GROUP --plan $aspName

printf "\Create keyvault for Git PAT - 1/3 ... (4/5)\n\n"
az keyvault create -n $apikeyvault -g $RESOURCE_GROUP -l centralus

printf "\Set secret- 2/3 ... (4/5)\n\n"
az keyvault secret set --vault-name $apikeyvault --name $apiSecretName --value $GITPAT

printf "\Set policy - 3/3 ... (4/5)\n\n"
az keyvault set-policy -n $apikeyvault --secret-permissions get --upn $(az ad signed-in-user show --query userPrincipalName -o tsv)

printf "\nSetting the account-level deployment credentials ...(5/5)\n\n"
az webapp deployment source config --name $apiappname --resource-group $RESOURCE_GROUP --repo-url $gitUrl --branch master --git-token $GITPAT --manual-integration

# Create Web App with GitHub deploy

printf "Setup complete!\n\n"

printf "***********************    IMPORTANT INFO  *********************\n\n"

printf "Web API test URL: https://$apiappname.azurewebsites.net/api/quotes/usa/chess?height=7&width=6\n"

printf "Swagger URL: https://$apiappname.azurewebsites.net/swagger\n"

printf "Swagger JSON URL: https://$apiappname.azurewebsites.net/swagger/v1/swagger.json\n\n"
