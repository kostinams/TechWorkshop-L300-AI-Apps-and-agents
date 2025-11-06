# Azure Container Registry Deployment

This repository includes a GitHub Actions workflow to automatically build and deploy the AI Shopping Assistant application to Azure Container Registry (ACR).

## Setup Instructions

### 1. Create Azure Resources

First, you'll need to create an Azure Container Registry:

```bash
# Set variables
RESOURCE_GROUP="your-resource-group"
ACR_NAME="your-acr-name"
LOCATION="eastus"

# Create resource group (if it doesn't exist)
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create Azure Container Registry
az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Basic
```

### 2. Set up Azure Authentication (Recommended: OIDC)

For secure authentication without storing long-lived secrets, set up OpenID Connect (OIDC):

```bash
# Create a service principal and configure OIDC
az ad app create --display-name "github-actions-acr-deployment"
APP_ID=$(az ad app list --display-name "github-actions-acr-deployment" --query "[0].appId" -o tsv)

# Create service principal
az ad sp create --id $APP_ID
SP_ID=$(az ad sp list --display-name "github-actions-acr-deployment" --query "[0].id" -o tsv)

# Get your subscription and tenant IDs
SUBSCRIPTION_ID=$(az account show --query "id" -o tsv)
TENANT_ID=$(az account show --query "tenantId" -o tsv)

# Create role assignment for ACR
az role assignment create --role "AcrPush" --assignee $SP_ID --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.ContainerRegistry/registries/$ACR_NAME"

# Configure OIDC
az ad app federated-credential create --id $APP_ID --parameters '{
  "name": "github-actions-main",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:YOUR_GITHUB_USERNAME/YOUR_REPO_NAME:ref:refs/heads/main",
  "audiences": ["api://AzureADTokenExchange"]
}'
```

### 3. Configure GitHub Secrets

Add the following secrets to your GitHub repository (Settings > Secrets and variables > Actions):

#### Required Azure Secrets:
- `AZURE_CLIENT_ID`: The application (client) ID from step 2
- `AZURE_TENANT_ID`: Your Azure tenant ID
- `AZURE_SUBSCRIPTION_ID`: Your Azure subscription ID

#### Environment Variables Secret:
- `ENV`: The complete contents of your .env file as a single secret

**Example ENV secret content:**
```
OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT="true"
AZURE_OPENAI_ENDPOINT="https://your-openai-resource.openai.azure.com/"
AZURE_OPENAI_KEY="your-openai-key"
AZURE_OPENAI_API_VERSION="2024-12-01-preview"
AZURE_AI_AGENT_ENDPOINT="https://your-ai-agent-endpoint"
AZURE_AI_AGENT_MODEL_DEPLOYMENT_NAME="gpt-4.1"
AZURE_AI_AGENT_API_VERSION="2024-12-01-preview"
interior_designer="your-interior-designer-id"
customer_loyalty="your-customer-loyalty-id"
inventory_agent="your-inventory-agent-id"
cora="your-cora-id"
gpt_endpoint="https://your-gpt-endpoint"
gpt_deployment="gpt-4.1"
```

### 4. Update Workflow Configuration

Edit `.github/workflows/deploy-to-acr.yml` and update the `REGISTRY_NAME` environment variable:

```yaml
env:
  REGISTRY_NAME: 'your-acr-name' # Replace with your ACR name
  IMAGE_NAME: 'ai-shopping-assistant'
  IMAGE_TAG: ${{ github.sha }}
```

## How It Works

### Workflow Triggers
- **Push to main branch**: Automatically triggers when changes are pushed to the `src/` folder
- **Manual dispatch**: Can be triggered manually from the GitHub Actions tab

### Build Process
1. **Checkout code**: Downloads the repository code
2. **Set up Docker**: Configures Docker Buildx for advanced features
3. **Azure login**: Authenticates with Azure using OIDC
4. **ACR login**: Logs into your Azure Container Registry
5. **Create .env file**: Securely creates the .env file from the GitHub secret
6. **Build and push**: Builds the Docker image and pushes it to ACR with two tags:
   - `latest`: Always points to the most recent build
   - `<commit-sha>`: Specific version tied to the git commit
7. **Cleanup**: Removes the .env file from the runner for security

### Security Features
- ✅ Uses OIDC authentication (no long-lived secrets)
- ✅ .env file is created only during build and immediately cleaned up
- ✅ .env file is never committed to the repository
- ✅ Uses Docker layer caching for faster builds
- ✅ Only includes necessary files in the Docker context

### Image Tags
After a successful build, your image will be available at:
- `your-acr-name.azurecr.io/ai-shopping-assistant:latest`
- `your-acr-name.azurecr.io/ai-shopping-assistant:<commit-sha>`

## Local Development

For local development, create a `.env` file in the `src/` directory based on `env_sample.txt`. This file is git-ignored and will not be committed.

## Troubleshooting

### Common Issues

1. **ACR access denied**: Ensure the service principal has the `AcrPush` role
2. **Environment variables not found**: Check that the `ENV` secret contains all required variables
3. **Build context too large**: Review `.dockerignore` to exclude unnecessary files
4. **Authentication failures**: Verify OIDC configuration and GitHub secrets

### Debugging
- Check the Actions tab in GitHub for detailed build logs
- Verify ACR permissions: `az acr repository list --name your-acr-name`
- Test local Docker build: `docker build -t test-image ./src`

## Next Steps

After successful deployment to ACR, you can:
1. Deploy to Azure Container Instances (ACI)
2. Deploy to Azure Container Apps
3. Deploy to Azure Kubernetes Service (AKS)
4. Set up additional environments (staging, production)

## Security Best Practices

- ✅ Never commit .env files or secrets to the repository
- ✅ Use OIDC instead of service principal passwords
- ✅ Regularly rotate secrets and keys
- ✅ Use least-privilege access for service principals
- ✅ Monitor ACR access and usage