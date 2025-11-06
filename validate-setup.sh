#!/bin/bash

# GitHub Actions ACR Deployment Validation Script
# This script helps validate that your setup is correct before pushing

echo "🔍 Validating GitHub Actions ACR Deployment Setup..."
echo

# Check if workflow file exists
if [ -f ".github/workflows/deploy-to-acr.yml" ]; then
    echo "✅ GitHub Actions workflow file exists"
else
    echo "❌ GitHub Actions workflow file missing"
    exit 1
fi

# Check if Dockerfile exists in src/
if [ -f "src/Dockerfile" ]; then
    echo "✅ Dockerfile exists in src/ directory"
else
    echo "❌ Dockerfile missing from src/ directory"
    exit 1
fi

# Check if .dockerignore exists
if [ -f "src/.dockerignore" ]; then
    echo "✅ .dockerignore file exists"
else
    echo "⚠️  .dockerignore file missing (recommended)"
fi

# Check if .env is in .gitignore
if grep -q "\.env" .gitignore; then
    echo "✅ .env files are properly gitignored"
else
    echo "❌ .env files not found in .gitignore"
fi

# Check if there's an accidental .env file
if [ -f "src/.env" ]; then
    echo "⚠️  Found .env file in src/ - make sure it's not committed!"
else
    echo "✅ No .env file found in src/ (good for security)"
fi

# Check if env_sample.txt exists
if [ -f "src/env_sample.txt" ]; then
    echo "✅ Environment sample file exists"
else
    echo "⚠️  No environment sample file found"
fi

echo
echo "📋 Next steps:"
echo "1. Create Azure Container Registry"
echo "2. Set up OIDC authentication with Azure"  
echo "3. Add GitHub secrets: AZURE_CLIENT_ID, AZURE_TENANT_ID, AZURE_SUBSCRIPTION_ID, ENV"
echo "4. Update REGISTRY_NAME in the workflow file"
echo "5. Push to main branch to trigger deployment"
echo
echo "📖 See DEPLOYMENT.md for detailed instructions"