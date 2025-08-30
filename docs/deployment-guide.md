# Deployment Guide

## Prerequisites
- Azure CLI (2.40.0+) and Bicep CLI (0.12.0+)
- Azure Subscription with Owner or Contributor rights
- PowerShell 7+ or Bash (for scripting)

## Setup
1. Clone the repository:
   ```
   git clone https://github.com/a-ariff/azure-landing-zone-bicep.git
   cd azure-landing-zone-bicep
   ```
2. Login to Azure:
   ```
   az login
   az account set --subscription "<YourSubName>"
   ```
3. Install/upgrade Bicep:
   ```
   az bicep upgrade
   ```

## Deployment Steps
1. **Parameter files:**
   - Copy example parameter files from `/parameters/dev/...` and customize for your environment.
2. **Deploy core infrastructure:**
   ```
   az deployment sub create \
     --location <azure-region> \
     --template-file bicep/main.bicep \
     --parameters @parameters/dev/main.parameters.json
   ```
3. **Deploy modules as needed:**
   - For networking: `bicep/core/networking/*`
   - For security: `bicep/core/security/*`
   - For VMs: `bicep/core/compute/*`

## Tips
- Review and update parameters for each environment (dev, staging, prod).
- Leverage GitHub Actions, Azure DevOps, or your preferred CI/CD for automated deployment.

## Advanced
- Use management groups for environment separation.
- Adjust policy assignments to fit your compliance needs.

For additional details on parameters or error handling, see `/docs/troubleshooting.md`.
