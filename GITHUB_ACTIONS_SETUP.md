# Customer Loyalty Agent GitHub Actions Workflow

This document describes the GitHub Actions workflow that automatically executes the Customer Loyalty Agent when specific files are modified.

## Trigger Conditions

The workflow executes when changes are made to any of the following files:
- `src/app/agents/customerLoyaltyAgent_initializer.py`
- `src/prompts/CustomerLoyaltyAgentPrompt.txt`
- `src/app/tools/discountLogic.py`

The workflow triggers on:
- Push to the `main` branch
- Pull requests targeting the `main` branch

## Required GitHub Secrets

Before using this workflow, you must configure the following secrets in your GitHub repository settings:

### Azure Authentication
- `AZURE_CREDENTIALS`: JSON object containing service principal credentials for Azure CLI login
  ```json
  {
    "clientId": "<service-principal-client-id>",
    "clientSecret": "<service-principal-client-secret>",
    "subscriptionId": "<azure-subscription-id>",
    "tenantId": "<azure-tenant-id>"
  }
  ```
- `AZURE_CLIENT_ID`: The client ID of your Azure service principal
- `AZURE_CLIENT_SECRET`: The client secret of your Azure service principal  
- `AZURE_TENANT_ID`: Your Azure tenant ID

### Azure AI Projects Configuration
- `AZURE_AI_AGENT_ENDPOINT`: The endpoint URL for your Azure AI Projects resource
- `AZURE_AI_AGENT_MODEL_DEPLOYMENT_NAME`: The name of your AI model deployment

### Application Insights
- `APPLICATIONINSIGHTS_CONNECTION_STRING`: Connection string for Azure Application Insights for telemetry

## How to Set Up Azure Service Principal

1. Create a service principal using Azure CLI:
   ```bash
   az ad sp create-for-rbac --name "github-actions-customer-loyalty" --role contributor --scopes /subscriptions/{subscription-id}
   ```

2. The command will return JSON similar to:
   ```json
   {
     "appId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
     "displayName": "github-actions-customer-loyalty",
     "password": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
     "tenant": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
   }
   ```

3. Use these values to set up your GitHub secrets:
   - `AZURE_CLIENT_ID` = `appId`
   - `AZURE_CLIENT_SECRET` = `password`
   - `AZURE_TENANT_ID` = `tenant`
   - `AZURE_CREDENTIALS` = entire JSON object with `clientId`, `clientSecret`, `subscriptionId`, and `tenantId`

## Workflow Steps

1. **Checkout**: Downloads the repository code
2. **Python Setup**: Installs Python 3.11 with pip caching
3. **Dependencies**: Installs required packages from `src/requirements.txt`
4. **Azure Login**: Authenticates with Azure using service principal credentials
5. **Connection Validation**: Tests the connection to Azure AI Projects
6. **Agent Execution**: Runs the Customer Loyalty Agent initializer
7. **Cleanup**: Performs any necessary resource cleanup
8. **Error Handling**: Uploads logs if the workflow fails

## Security Best Practices

- Uses Azure Managed Identity when possible
- Never hardcodes credentials in the workflow
- All sensitive information is stored as GitHub secrets
- Implements proper error handling and cleanup
- Uses least privilege principle for Azure permissions

## Troubleshooting

If the workflow fails:

1. Check that all required secrets are properly configured
2. Verify Azure service principal has necessary permissions
3. Review the uploaded logs artifact for detailed error information
4. Ensure the Azure AI Projects endpoint is accessible
5. Confirm the model deployment name is correct

## Monitoring

The workflow includes:
- Connection validation before execution
- Proper error handling and logging
- Artifact upload for debugging failed runs
- Timeout protection (15 minutes maximum)