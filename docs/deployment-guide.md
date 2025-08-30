# Deployment Guide

## Overview

This guide provides step-by-step instructions for deploying the Azure Landing Zone Bicep infrastructure. It covers prerequisites, deployment procedures, configuration options, and post-deployment validation.

## Prerequisites

### Required Tools
- **Azure CLI**: Version 2.40.0 or later
- **Bicep CLI**: Version 0.12.0 or later
- **PowerShell**: Version 7.0+ or Bash
- **Git**: For repository management
- **Visual Studio Code**: Recommended with Azure and Bicep extensions

### Azure Requirements
- Azure subscription with Owner or Contributor permissions
- Azure Active Directory tenant
- Sufficient subscription quotas for planned resources
- Required resource providers registered

### Account Permissions
- Subscription Owner or Contributor role
- User Access Administrator role (for RBAC assignments)
- Global Administrator role in Azure AD (for certain operations)

## Installation and Setup

### 1. Install Azure CLI

**Windows:**
```powershell
# Using Chocolatey
choco install azure-cli

# Using MSI installer
# Download from https://aka.ms/installazurecliwindows
```

**macOS:**
```bash
# Using Homebrew
brew install azure-cli
```

**Linux:**
```bash
# Ubuntu/Debian
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# CentOS/RHEL/Fedora
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo dnf install azure-cli
```

### 2. Install Bicep CLI

```bash
# Install via Azure CLI
az bicep install

# Verify installation
az bicep version
```

### 3. Clone Repository

```bash
git clone https://github.com/a-ariff/azure-landing-zone-bicep.git
cd azure-landing-zone-bicep
```

## Configuration

### 1. Azure Authentication

```bash
# Login to Azure
az login

# Set default subscription
az account set --subscription "<subscription-id>"

# Verify current subscription
az account show
```

### 2. Parameter Configuration

Copy and customize the parameter files for your environment:

```bash
# Development environment
cp parameters/dev/main.parameters.json.example parameters/dev/main.parameters.json

# Staging environment
cp parameters/staging/main.parameters.json.example parameters/staging/main.parameters.json

# Production environment
cp parameters/production/main.parameters.json.example parameters/production/main.parameters.json
```

### 3. Key Parameters to Configure

#### Basic Configuration
```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "organizationName": {
      "value": "contoso"
    },
    "location": {
      "value": "East US"
    },
    "environment": {
      "value": "dev"
    }
  }
}
```

#### Network Configuration
```json
{
  "hubVirtualNetwork": {
    "value": {
      "name": "hub-vnet",
      "addressPrefix": "10.0.0.0/16",
      "subnets": {
        "AzureFirewallSubnet": "10.0.1.0/24",
        "GatewaySubnet": "10.0.2.0/24",
        "AzureBastionSubnet": "10.0.3.0/24"
      }
    }
  },
  "spokeVirtualNetworks": {
    "value": [
      {
        "name": "spoke1-vnet",
        "addressPrefix": "10.1.0.0/16",
        "subnets": {
          "web": "10.1.1.0/24",
          "app": "10.1.2.0/24",
          "data": "10.1.3.0/24"
        }
      }
    ]
  }
}
```

## Deployment Process

### 1. Validate Deployment

Before deploying, validate the templates:

```bash
# Validate main template
az deployment sub validate \
  --location "East US" \
  --template-file bicep/main.bicep \
  --parameters @parameters/dev/main.parameters.json
```

### 2. What-If Analysis

Review what resources will be created:

```bash
az deployment sub what-if \
  --location "East US" \
  --template-file bicep/main.bicep \
  --parameters @parameters/dev/main.parameters.json
```

### 3. Deploy Infrastructure

#### Development Environment
```bash
az deployment sub create \
  --name "landing-zone-dev-$(date +%Y%m%d-%H%M%S)" \
  --location "East US" \
  --template-file bicep/main.bicep \
  --parameters @parameters/dev/main.parameters.json
```

#### Staging Environment
```bash
az deployment sub create \
  --name "landing-zone-staging-$(date +%Y%m%d-%H%M%S)" \
  --location "East US" \
  --template-file bicep/main.bicep \
  --parameters @parameters/staging/main.parameters.json
```

#### Production Environment
```bash
az deployment sub create \
  --name "landing-zone-prod-$(date +%Y%m%d-%H%M%S)" \
  --location "East US" \
  --template-file bicep/main.bicep \
  --parameters @parameters/production/main.parameters.json
```

### 4. Monitor Deployment

```bash
# Check deployment status
az deployment sub show \
  --name "landing-zone-dev-<timestamp>" \
  --query "properties.provisioningState"

# View deployment operations
az deployment operation sub list \
  --name "landing-zone-dev-<timestamp>"
```

## Post-Deployment Configuration

### 1. Verify Resource Deployment

```bash
# List deployed resource groups
az group list --query "[?contains(name, 'contoso')].{Name:name, Location:location}"

# Check specific resource groups
az resource list --resource-group "rg-contoso-hub-dev" --output table
```

### 2. Configure Azure Policies

Apply governance policies:

```bash
# Deploy policy assignments
az deployment sub create \
  --template-file policies/governance/main.bicep \
  --parameters @policies/governance/parameters.json
```

### 3. Set Up Monitoring

```bash
# Configure Log Analytics workspace
az monitor log-analytics workspace create \
  --resource-group "rg-contoso-monitoring-dev" \
  --workspace-name "law-contoso-dev"

# Enable diagnostic settings
az monitor diagnostic-settings create \
  --name "diagnostic-settings" \
  --resource "/subscriptions/<subscription-id>/resourceGroups/rg-contoso-hub-dev" \
  --workspace "/subscriptions/<subscription-id>/resourceGroups/rg-contoso-monitoring-dev/providers/Microsoft.OperationalInsights/workspaces/law-contoso-dev"
```

### 4. Configure Backup Policies

```bash
# Create Recovery Services vault
az backup vault create \
  --resource-group "rg-contoso-backup-dev" \
  --name "rsv-contoso-dev" \
  --location "East US"

# Set up VM backup policy
az backup policy create \
  --vault-name "rsv-contoso-dev" \
  --resource-group "rg-contoso-backup-dev" \
  --name "vm-backup-policy" \
  --policy vm-backup-policy.json
```

## Deployment Patterns

### 1. Single Environment Deployment
Deploy one environment at a time for testing and validation.

### 2. Multi-Environment Pipeline
Use CI/CD pipelines for automated deployments across environments.

### 3. Blue-Green Deployment
Deploy to a parallel environment before switching traffic.

### 4. Incremental Updates
Deploy individual modules or components independently.

## Troubleshooting

### Common Issues

#### 1. Insufficient Permissions
```bash
# Check current permissions
az role assignment list --assignee $(az account show --query user.name -o tsv)

# Grant required permissions
az role assignment create \
  --assignee "<user-principal-name>" \
  --role "Owner" \
  --scope "/subscriptions/<subscription-id>"
```

#### 2. Resource Provider Not Registered
```bash
# Register required providers
az provider register --namespace Microsoft.Network
az provider register --namespace Microsoft.Compute
az provider register --namespace Microsoft.Storage
az provider register --namespace Microsoft.KeyVault

# Check registration status
az provider list --query "[?registrationState=='Registered'].{Namespace:namespace}" --output table
```

#### 3. Quota Limitations
```bash
# Check current usage and limits
az vm list-usage --location "East US" --output table
az network list-usages --location "East US" --output table

# Request quota increase through Azure portal
```

#### 4. Template Validation Errors
```bash
# Validate individual modules
az deployment group validate \
  --resource-group "rg-test" \
  --template-file bicep/core/networking/hub-vnet.bicep \
  --parameters @parameters/dev/networking.parameters.json
```

### Debugging Commands

```bash
# Get deployment error details
az deployment sub show \
  --name "landing-zone-dev-<timestamp>" \
  --query "properties.error"

# View operation details
az deployment operation sub list \
  --name "landing-zone-dev-<timestamp>" \
  --query "[?properties.provisioningState=='Failed'].{OperationId:operationId, Error:properties.statusMessage.error}"
```

## Best Practices

### 1. Deployment Strategy
- Always validate templates before deployment
- Use what-if analysis to preview changes
- Deploy to development environment first
- Implement proper change management processes

### 2. Parameter Management
- Use separate parameter files for each environment
- Store sensitive parameters in Azure Key Vault
- Version control all parameter files
- Document parameter dependencies

### 3. Monitoring and Logging
- Enable diagnostic settings for all resources
- Set up alerts for deployment failures
- Monitor resource utilization and costs
- Implement proper backup and recovery procedures

### 4. Security Considerations
- Use managed identities where possible
- Implement least privilege access
- Enable Azure Security Center recommendations
- Regular security assessments and reviews

## Cleanup and Rollback

### 1. Resource Cleanup
```bash
# Delete resource groups
az group delete --name "rg-contoso-hub-dev" --yes --no-wait
az group delete --name "rg-contoso-spoke1-dev" --yes --no-wait

# Clean up at subscription level
az deployment sub delete --name "landing-zone-dev-<timestamp>"
```

### 2. Rollback Procedures
```bash
# Redeploy previous version
az deployment sub create \
  --name "landing-zone-rollback-$(date +%Y%m%d-%H%M%S)" \
  --location "East US" \
  --template-file bicep/main-previous.bicep \
  --parameters @parameters/dev/main.parameters.json
```

## Next Steps

After successful deployment:

1. Review the [Architecture Overview](architecture/overview.md)
2. Implement [Best Practices](best-practices.md)
3. Set up monitoring and alerting
4. Configure backup and disaster recovery
5. Implement security hardening
6. Plan for scaling and growth

For additional support, refer to the [Troubleshooting Guide](troubleshooting.md) or create an issue in the repository.
