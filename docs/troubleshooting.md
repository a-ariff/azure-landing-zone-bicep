# Troubleshooting

This guide helps identify and resolve common issues when deploying or managing the Azure Landing Zone using Bicep.

## Common Errors & Solutions
### 1. Validation Errors
- **Cause:** Parameters missing or invalid values.
- **Solution:** Double-check required parameters; use `bicep build` and `bicep linter` to validate files.

### 2. Permission Denied
- **Cause:** Insufficient Azure RBAC permissions.
- **Solution:** Ensure the account has at least 'Contributor' rights. For policy, role or management group actions, 'Owner' may be required.

### 3. Module Not Found
- **Cause:** Bicep module reference path is wrong or module file missing.
- **Solution:** Check README for module structure. Confirm referenced files exist in `bicep/`.

### 4. Resource Already Exists
- **Cause:** Name collision on resource group, VNet, or subnet.
- **Solution:** Use unique names or clean up old resources before redeployment.

### 5. Deployment Quota Exceeded
- **Cause:** Subscription/resource group quota limits hit.
- **Solution:** Review quota in Azure Portal. Request quota increases as needed.

## Diagnostics & Support
- Use `az deployment sub validate` before running full deployment.
- Check Azure Activity Log and Resource Health for errors.
- Use `bicep --help` and `az deployment -h` for command line help.
- For issues with Azure Policy/Blueprints, use built-in Portal audit and compliance reports.

## Getting More Help
- Search open and closed issues in this repo.
- Create a new GitHub issue with error message and steps to reproduce.
- Consult official Microsoft docs for [Bicep](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/) and [Cloud Adoption Framework](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/).
