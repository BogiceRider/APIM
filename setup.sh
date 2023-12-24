#!/bin/bash
apiappname=bogice-apim
apikeyvault=bogice-apim-kv
apiSecretName=Git-PAT
RESOURCE_GROUP=bogice-rg
upn=huyanh.ng@gmail.com
gitUrl=https://github.com/BogiceRider/APIM.git

# Create App Service plan
PLAN_NAME=bogice-asp

printf "\nCreating App Service plan in FREE tier ... (2/7)\n\n"

az appservice plan create --name $apiappname --resource-group $RESOURCE_GROUP --sku FREE --location centralus

printf "\nCreating API App ... (3/7)\n\n"

az webapp create --name $apiappname --resource-group $RESOURCE_GROUP --plan $apiappname

printf "\nSetting the account-level deployment credentials ...(4/7)\n\n"


az keyvault create -n $apikeyvault -g $RESOURCE_GROUP -l centralus

az keyvault secret set --vault-name $apikeyvault --name $apiSecretName --value "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"

az keyvault set-policy -n $apikeyvault --secret-permissions get --upn $upn

GITPAT=$(az keyvault secret show --vault-name $apikeyvault --name $apiSecretName --query value -o tsv)

az webapp deployment source config --name $apiappname --resource-group $RESOURCE_GROUP --repo-url $gitUrl --branch master --git-token $GITPAT --mamual-integration

# Create Web App with GitHub deploy

printf "Setup complete!\n\n"

printf "***********************    IMPORTANT INFO  *********************\n\n"

printf "Web API test URL: https://$apiappname.azurewebsites.net/api/quotes/usa/chess?height=7&width=6\n"

printf "Swagger URL: https://$apiappname.azurewebsites.net/swagger\n"

printf "Swagger JSON URL: https://$apiappname.azurewebsites.net/swagger/v1/swagger.json\n\n"
